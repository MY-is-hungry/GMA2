class LinebotController < ApplicationController
    require 'line/bot'  # gem 'line-bot-api'
    require "json" #jsonモジュールを利用
    require "open-uri" #Webサイトにアクセスできるようにする。
    require "date" #TimeZone
    include BaseRequest
    include BadRequest
    
    # callbackアクションのCSRFトークン認証を無効
    protect_from_forgery :except => [:callback]
    
    def get_commute(event)
      Commute.find_by(user_id: event['source']['userId'])
    end
    
    def callback
      body = request.body.read
      
      #LINEからのリクエストか確認
      signature = request.env['HTTP_X_LINE_SIGNATURE']
      unless client.validate_signature(body, signature)
        head :bad_request
      end
      
      #Webhookイベントオブジェクト
      events = client.parse_events_from(body)

      events.each { |event|
        case event
        when Line::Bot::Event::Message
          case event.type
          when Line::Bot::Event::MessageType::Text #テキストメッセージが来た場合
            commute = get_commute(event)
            message = event.message['text']
            case message
            when 'おはよう'
              data = Array.new
              logger.debug(commute.start_address)
              logger.debug(commute.end_address)
              if commute.start_address == commute.end_address
                start_response = open(ENV['W_URL'] + "?zip=#{commute.start_address},jp&units=metric&lang=ja&cnt=6&APPID=" + ENV['W_KEY'])
                data[0] = JSON.parse(start_response.read, {symbolize_names: true})
              else
                start_response = open(ENV['W_URL'] + "?zip=#{commute.start_address},jp&units=metric&lang=ja&cnt=6&APPID=" + ENV['W_KEY'])
                end_response = open(ENV['W_URL'] + "?zip=#{commute.end_address},jp&units=metric&lang=ja&cnt=6&APPID=" + ENV['W_KEY'])
                #JSONデータをハッシュ化
                data[0] = JSON.parse(start_response.read, {symbolize_names: true})
                data[1] = JSON.parse(end_response.read, {symbolize_names: true})
                logger.debug(data[1])
              end
              reply = change_msg(message, data: data)
              
            when '基本設定'
              reply = change_msg(message, commute: commute)

            when '通勤設定'
              reply = change_msg(message, state: commute.get_state)
              commute.update(start_lat: nil,start_lng: nil,end_lat: nil,end_lng: nil)
              commute.via_place.destroy_all

            when '通勤モード'
              reply = commute.get_state.in?([0, 1]) ? change_msg(message) : bad_msg(message)

            when '出発地点変更'
              reply = change_msg(message, state: commute.get_state)
              logger.debug(commute.setup_id)
              commute.update(start_lat: nil,start_lng: nil)
              commute.update(setup_id: commute.get_setup_id)
              logger.debug(commute.setup_id)
              commute.via_place.destroy_all

            when '到着地点変更'
              reply = change_msg(message, state: commute.get_state)
              commute.update(end_lat: nil,end_lng: nil)
              commute.via_place.destroy_all

            when '中間地点登録'
              state = commute.get_state
              reply = state.in?([0, 1]) ? change_msg(message) : bad_msg(message)

            when '中間地点削除'
              reply =
                if commute.via_place.first
                  ViaPlace.where(commute_id: commute.id).destroy_all
                  change_msg(message)
                else
                  bad_msg(message)
                end

            when '経路の制限'
              commute.get_state
              commute.update(avoid: nil)
              reply = commute.get_state.in?([0, 1]) ? change_msg(message, commute: commute) : bad_msg(message)
              
            when '通勤時間'
              state = commute.get_state
              return client.reply_message(event['replyToken'], bad_msg(message)) if state.in?([2,3,4])
              time = Time.parse(Time.now.to_s).to_i #現在時刻をAPIで使用するため、UNIX時間に変換
              logger.debug(commute.avoid)
              if commute.mode
                case state
                when 0
                  w = ""
                  via = ViaPlace.where(commute_id: commute.id).order(:order)
                  location = Array.new
                  via.each_with_index do |v, n|
                    location[n] = {lat: v.via_lat, lng: v.via_lng}
                  end
                  location.each do |l|
                    w = w + "via:#{l[:lat]},#{l[:lng]}|"
                  end
                  response = open(ENV['G_DIRECTION_URL'] + "origin=#{commute.start_lat},#{commute.start_lng}&destination=#{commute.end_lat},#{commute.end_lng}
                  &waypoints=#{w}&avoid=#{commute.avoid}&departure_time=#{time}&traffic_model=#{commute.mode}&language=ja&key=" + ENV['G_KEY'])
                when 1
                  response = open(ENV['G_DIRECTION_URL'] + "origin=#{commute.start_lat},#{commute.start_lng}&destination=#{commute.end_lat},#{commute.end_lng}
                  &avoid=#{commute.avoid}&departure_time=#{time}&traffic_model=#{commute.mode}&language=ja&key=" + ENV['G_KEY'])
                end
                data = JSON.parse(response.read, {symbolize_names: true})
                reply = {type: "text",text: "#{data[:routes][0][:legs][0][:duration_in_traffic][:text]}"}
              else
                response = open(ENV['G_DIRECTION_URL'] + "origin=#{commute.start_lat},#{commute.start_lng}&destination=#{commute.end_lat},#{commute.end_lng}
                &avoid=#{commute.avoid}&language=ja&key=" + ENV['G_KEY'])
                data = JSON.parse(response.read, {symbolize_names: true})
                reply = {type: "text",text: "#{data[:routes][0][:legs][0][:duration][:text]}"}
              end

            when '寄り道地域'
              state = commute.get_state
              reply = state.in?([0, 1]) ? change_msg(message, state: state) : bad_msg(message)
            
            when '寄り道する！'
              state = commute.get_state
              reply = state.in?([0, 1]) ? change_msg(message) : bad_msg(message)
              
            when 'お気に入り'
              fav_id = Favorite.where(user_id: commute.user_id).pluck(:place_id)
              return client.reply_message(event['replyToken'], bad_msg(message)) unless fav_id.first
              array = Array.new
              fav_id.each_with_index do |f,n|
                response = open(URI.encode ENV['G_DETAIL_URL'] + "&place_id=#{f}&fields=name,formatted_address,photo,url,place_id&language=ja&key=" + ENV['G_KEY'])
                array[n] = JSON.parse(response.read, {symbolize_names: true})
              end
              data = Array.new
              array.each_with_index do |a,n|
                data[n] = Hash.new
                #写真が無いとフロント部分が崩れるので存在を確認
                a[:result].has_key?(:photos) ? photo = ENV['G_PHOTO_URL'] + "maxwidth=2000&photoreference=#{a[:result][:photos][0][:photo_reference]}&key=" + ENV['G_KEY'] : photo = "https://scdn.line-apps.com/n/channel_devcenter/img/fx/01_1_cafe.png"
                data[n] = {photo: photo, name: a[:result][:name], address: a[:result][:formatted_address], url: a[:result][:url], place_id: a[:result][:place_id]}
              end
              reply = change_msg(message, data: data, count: data.count)

            when 'ヘルプ'
              reply = change_msg(message)
            
            when 'リセット'
              state = commute.get_state
              if state.in?([0,1,2,3])
                commute.update(start_lat: nil,start_lng: nil,end_lat: nil,end_lng: nil, avoid: nil, mode: nil, setup_id: 5, basic_setup_status: false)
                commute.via_place.destroy_all
                reply = change_msg(message, state: state)
              else
                reply = bad_msg(message)
              end
              
            when 'テスト'
              
            else
              return client.reply_message(event['replyToken'], {type: 'text', text: 'そのコマンドは存在しません。'})
            end
            client.reply_message(event['replyToken'], reply)
            
          when Line::Bot::Event::MessageType::Location #位置情報が来た場合
            commute = get_commute(event)
            state = commute.get_state
            case state
            when 0,1 #中間地点登録
              count = ViaPlace.where(commute_id: commute.id).count + 1
              ViaPlace.create(commute_id: commute.id, via_lat: event.message['latitude'], via_lng: event.message['longitude'], order: count)
              reply = {type: 'text', text: "#{count}つ目の中間地点を登録しました。"}
              client.reply_message(event['replyToken'], reply)
              
            when 2 #到着地変更
              address = event.message['address'].scan(/\d{3}-\d{4}/)
              commute.update(end_lat: event.message['latitude'], end_lng: event.message['longitude'], end_address: address[0])
              logger.debug(commute.setup_id)
              commute.update(setup_id: commute.get_setup_id)
              logger.debug(commute.setup_id)
              reply = change_msg('end_location', commute: commute)
              
            when 3 #出発地のみ変更
              address = event.message['address'].scan(/\d{3}-\d{4}/)
              logger.debug(commute.setup_id)
              commute.update(start_lat: event.message['latitude'], start_lng: event.message['longitude'], start_address: address[0])
              commute.update(setup_id: commute.get_state)
              logger.debug(commute.setup_id)
              reply = {type: 'text',text: "出発地点を登録しました。"}
 
            when 4 #初期設定or全部変更
              commute.update(start_lat: event.message['latitude'], start_lng: event.message['longitude'])
              reply = change_msg('通勤設定2')
            else #エラー
              reply = bad_msg('該当コマンドなし')
            end
            client.reply_message(event['replyToken'], reply)
          end
          
        when Line::Bot::Event::Postback
          user = User.find_by(id: event['source']['userId'])
          commute = Commute.find_by(user_id: user.id)
          logger.debug(commute.setup_id)
          data = event['postback']['data']
          code = data.slice!(-1).to_i
          case code
          when 1 #通勤モード変更
            commute.update(mode: data)
            commute.update(setup_id: commute.get_setup_id)
            reply = change_msg('mode', commute: commute)
            
          when 2 #寄り道機能のお気に入り登録
            if Favorite.where(user_id: user.id).count < 5
              Favorite.create(user_id: user.id, place_id: data)
              reply = {type: 'text', text: "お気に入りに登録しました。"}
            else
              reply = [{
                type: 'text',
                text: "登録に失敗しました。\nお気に入りは最大5件までです。"},{
                type: 'text',
                text: "お気に入りの店舗を減らしてからもう一度お試しください。\n「お気に入り」と入力すると、現在のお気に入り店舗一覧が表示できます。"}
              ]
            end
          when 3 #お気に入りの解除
            Favorite.find_by(user_id: user.id,place_id: data).destroy
            reply = {type: 'text',text: "お気に入りを解除しました。"}
            
          when 4 #経路の制限の変更・設定完了
            avoid = commute.avoid ? commute.avoid.split('|') : []
            case data
            when '完了'
              message = '完了'
            when 'tolls', 'highways', 'ferries' #有料道路、高速道路、フェリーのいずれか
              return client.reply_message(event['replyToken'], bad_msg('avoid')) if avoid.include?(data)
              avoid.push(data)
              message = '変更'
            when 'none', 'tolls,highways,ferries' #全て使用する、全て使用しないのいずれか
              avoid = data.split(',')
              message = '変更'
            end
            commute.update(avoid: avoid.join('|'), setup_id: commute.get_setup_id)
            reply = change_msg(message, data: data, commute: commute)

          when 5 #寄り道機能の検索位置を設定
            commute.update(search_area: data.to_i)
            reply = {type: 'text',text: "検索エリアの設定が完了しました。"}
            
          when 6 #寄り道するお店を選択
            if commute.search_area
              response =
                case commute.search_area #寄り道地域設定済み
                when 1 #自宅付近
                  open(URI.encode ENV['G_SEARCH_URL'] + "query=#{data}&location=#{commute.start_lat},#{commute.start_lng}&radius=800&language=ja&key=" + ENV['G_KEY'])
                when 2 #職場付近
                  open(URI.encode ENV['G_SEARCH_URL'] + "query=#{data}&location=#{commute.end_lat},#{commute.end_lng}&radius=800&language=ja&key=" + ENV['G_KEY'])
                when 3 #中間地点付近（職場に最も近い中間地点）
                  open(URI.encode ENV['G_SEARCH_URL'] + "query=#{data}&location=#{commute.via_place.last.via_lat},#{commute.via_place.last.via_lng}&radius=1500&language=ja&key=" + ENV['G_KEY'])
                end
            elsif commute.get_state.in?([0, 1]) #寄り道地域は未設定だが、通勤場所は設定済み（職場付近で検索）
              response = open(URI.encode ENV['G_SEARCH_URL'] + "query=#{data}&location=#{commute.end_lat},#{commute.end_lng}&radius=800&language=ja&key=" + ENV['G_KEY'])
            else
              return client.reply_message(event['replyToken'], bad_msg(data))
            end
            hash = JSON.parse(response.read, {symbolize_names: true})
            #配列にハッシュ化した店舗データを入れる（最大５件）
            array = Array.new
            5.times do |n|
              array[n] = Hash.new
              #写真、評価、クチコミが無いとフロント部分が崩れるので存在を確認
              hash[:results][n].has_key?(:photos) ? photo = ENV['G_PHOTO_URL'] + "maxwidth=2000&photoreference=#{hash[:results][n][:photos][0][:photo_reference]}&key=" + ENV['G_KEY'] : photo = "https://scdn.line-apps.com/n/channel_devcenter/img/fx/01_1_cafe.png"
              hash[:results][n].has_key?(:rating) ? rating = hash[:results][n][:rating] : rating = "未評価"
              hash[:results][n].has_key?(:user_ratings_total) ? review = hash[:results][n][:user_ratings_total] : review = "0"
              #経路用のGoogleMapURLをエンコード
              url = URI.encode ENV['G_STORE_URL'] + "&query=#{hash[:results][n][:name]}&query_place_id=#{hash[:results][n][:place_id]}"
              array[n] = {photo: photo, name: hash[:results][n][:name], rating: rating,
                review: review, address: hash[:results][n][:formatted_address], url: url, place_id: hash[:results][n][:place_id]
              }
            end
            reply = change_msg(data, data: array)
          end
          client.reply_message(event['replyToken'], reply)
          
        when Line::Bot::Event::Follow
          User.create(id: event['source']['userId'])
          Commute.create(user_id: event['source']['userId'], setup_id: 5, basic_setup_status: false)
          client.reply_message(event['replyToken'], change_msg("follow"))
        when Line::Bot::Event::Unfollow
          User.find_by(id: event['source']['userId']).destroy
        else
          client.reply_message(event['replyToken'], bad_msg('該当コマンドなし'))
        end
      }
      head :ok
    end

    private

    def client
      @client ||= Line::Bot::Client.new { |config|
        config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
        config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
      }
    end
end