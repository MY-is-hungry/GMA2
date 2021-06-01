class LinebotController < ApplicationController
    require 'line/bot'  # gem 'line-bot-api'
    require "json" #jsonモジュールを利用
    require "open-uri" #Webサイトをアクセス可能にする
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
      
      #Webhookイベントオブジェクトをeventsに代入
      events = client.parse_events_from(body)

      events.each { |event|
        @commute = get_commute(event)
        case event
        when Line::Bot::Event::Message
          case event.type
          when Line::Bot::Event::MessageType::Text #テキストメッセージが来た場合
            message = event.message['text']
            case message
            when 'おはよう'
              state = @commute.get_state
              return client.reply_message(event['replyToken'], bad_msg(message)) if state.in?([9,10,11,12,13,14])
              commute_time = get_commute_time(state)
              weather_data = []
              if @commute.start_address == @commute.end_address
                start_response = open(ENV['W_URL'] + "?zip=#{@commute.start_address},jp&units=metric&lang=ja&cnt=6&APPID=" + ENV['W_KEY'])
                weather_data[0] = JSON.parse(start_response.read, {symbolize_names: true})
              else
                start_response = open(ENV['W_URL'] + "?zip=#{@commute.start_address},jp&units=metric&lang=ja&cnt=6&APPID=" + ENV['W_KEY'])
                end_response = open(ENV['W_URL'] + "?zip=#{@commute.end_address},jp&units=metric&lang=ja&cnt=6&APPID=" + ENV['W_KEY'])
                #JSONデータをハッシュ化
                weather_data[0] = JSON.parse(start_response.read, {symbolize_names: true})
                weather_data[1] = JSON.parse(end_response.read, {symbolize_names: true})
              end
              reply = change_msg(message, data: weather_data, commute_time: commute_time)
              
            when '基本設定'
              reply = change_msg(message)

            when '通勤設定'
              reply = change_msg(message, state: @commute.get_state)
              @commute.update(start_lat: nil,start_lng: nil,end_lat: nil,end_lng: nil)
              @commute.via_place.destroy_all

            when '通勤モード'
              reply = @commute.get_state.in?([1,2,3,4,5,6,7,8]) ? change_msg(message) : bad_msg(message)

            when '出発地点変更', '到着地点変更'
              reply = change_msg(message, state: @commute.get_state)
              message == '出発地点変更' ? @commute.update(start_lat: nil,start_lng: nil) : @commute.update(end_lat: nil,end_lng: nil)
              @commute.update(setup_id: @commute.get_state)
              @commute.via_place.destroy_all

            when '中間地点登録'
              state = @commute.get_state
              reply = state.in?([1,2,3,4,5,6,7,8]) ? change_msg(message) : bad_msg(message)

            when '中間地点削除'
              reply =
                if @commute.via_place.first
                  ViaPlace.where(commute_id: @commute.id).destroy_all
                  change_msg(message)
                else
                  bad_msg(message)
                end

            when '経路の制限'
              @commute.update(avoid: nil)
              reply = @commute.get_state.in?([1,2,3,4,5,6,7,8]) ? change_msg(message) : bad_msg(message)
              
            when '通勤時間'
              state = @commute.get_state
              return client.reply_message(event['replyToken'], bad_msg(message)) if state.in?([9,10,11,12,13,14])
              commute_time = get_commute_time(state)
              reply = change_msg(message, data: commute_time, state: state)

            when '寄り道地域'
              state = @commute.get_state
              logger.debug(state)
              reply = state.in?([1,2,3,4,5,6,7,8]) ? change_msg(message, state: state) : bad_msg(message)
            
            when '寄り道する！'
              state = @commute.get_state
              logger.debug(state)
              reply = state.in?([1,2,3,4,5,6,7,8]) ? change_msg(message) : bad_msg(message)
              
            when 'お気に入り'
              fav_id = Favorite.where(user_id: @commute.user_id).pluck(:place_id)
              return client.reply_message(event['replyToken'], bad_msg(message)) unless fav_id.first
              box = []
              fav_id.each_with_index do |f,n|
                box[n] = {}
                response = open(URI.encode ENV['G_DETAIL_URL'] + "&place_id=#{f}&fields=name,formatted_address,photo,url,place_id&language=ja&key=" + ENV['G_KEY'])
                store_info = JSON.parse(response.read, {symbolize_names: true})
                store_info[:result].has_key?(:photos) ? photo = ENV['G_PHOTO_URL'] + "maxwidth=2000&photoreference=#{store_info[:result][:photos][0][:photo_reference]}&key=" + ENV['G_KEY'] : photo = "https://scdn.line-apps.com/n/channel_devcenter/img/fx/01_1_cafe.png"
                box[n] = {photo: photo, name: store_info[:result][:name], address: store_info[:result][:formatted_address], url: store_info[:result][:url], place_id: store_info[:result][:place_id]}
              end
              reply = change_msg(message, data: box, count: box.count)

            when 'ヘルプ'
              reply = change_msg(message)
            
            when 'リセット'
              state = @commute.get_state
              if state == 14
                reply = bad_msg(message)
              else
                @commute.update(start_lat: nil,start_lng: nil,end_lat: nil,end_lng: nil, avoid: nil, mode: nil, setup_id: 14, first_setup: false)
                @commute.via_place.destroy_all
                reply = change_msg(message, state: state)
              end
              
            when 'テスト'
              
            else
              return client.reply_message(event['replyToken'], {type: 'text', text: 'そのコマンドは存在しません。'})
            end
            logger.debug(reply)
            client.reply_message(event['replyToken'], reply)
            
          when Line::Bot::Event::MessageType::Location #位置情報が来た場合
            state = @commute.get_state
            case state
            when 1..8 #中間地点登録
              count = ViaPlace.where(commute_id: @commute.id).count + 1
              ViaPlace.create(commute_id: @commute.id, via_lat: event.message['latitude'], via_lng: event.message['longitude'], order: count)
              reply = change_msg('via_place', count: count, state: state)

            when 9 #到着地変更
              address = event.message['address'].scan(/\d{3}-\d{4}/)
              @commute.update(end_lat: event.message['latitude'], end_lng: event.message['longitude'], end_address: address[0])
              @commute.update(setup_id: @commute.get_state)
              reply = change_msg('end_location')
              
            when 10 #出発地のみ変更
              address = event.message['address'].scan(/\d{3}-\d{4}/)
              @commute.update(start_lat: event.message['latitude'], start_lng: event.message['longitude'], start_address: address[0])
              @commute.update(setup_id: @commute.get_state)
              reply = {type: 'text',text: "出発地点を登録しました。"}
 
            when 11..14 #初期設定or全部変更
              address = event.message['address'].scan(/\d{3}-\d{4}/)
              @commute.update(start_lat: event.message['latitude'], start_lng: event.message['longitude'], start_address: address[0])
              reply = change_msg('first_location')
            else #エラー
              reply = bad_msg('該当コマンドなし')
            end
            client.reply_message(event['replyToken'], reply)
          end
          
        when Line::Bot::Event::Postback
          user = User.find_by(id: event['source']['userId'])
          logger.debug(@commute.setup_id)
          data = event['postback']['data']
          code = data.slice!(-1).to_i
          case code
          when 1 #通勤モード変更
            @commute.update(mode: data)
            @commute.update(setup_id: @commute.get_state)
            reply = change_msg('mode')
            
          when 2 #寄り道機能のお気に入り登録
            reply =
              if Favorite.where(user_id: user.id).count < 5
                Favorite.create(user_id: user.id, place_id: data)
                {type: 'text', text: "お気に入りに登録しました。"}
              else
                 bad_msg('favorite_registration')
              end
          when 3 #お気に入りの解除
            Favorite.find_by(user_id: user.id,place_id: data).destroy
            reply = {type: 'text',text: "お気に入りを解除しました。"}
            
          when 4 #経路の制限の変更・設定完了
            avoid = @commute.avoid ? @commute.avoid.split('|') : []
            case data
            when '完了'
              message = 'completed'
            when 'tolls', 'highways', 'ferries' #有料道路、高速道路、フェリーのいずれか
              return client.reply_message(event['replyToken'], bad_msg('avoid')) if avoid.include?(data)
              avoid.push(data)
              message = 'changed'
            when 'none', 'tolls,highways,ferries' #全て使用する、全て使用しないのいずれか
              avoid = data.split(',')
              message = 'changed'
            end
            @commute.update(avoid: avoid.join('|'), setup_id: @commute.get_state)
            reply = change_msg(message, data: data)

          when 5 #寄り道機能の検索位置を設定
            @commute.update(search_area: data.to_i)
            reply = {type: 'text',text: "検索エリアの設定が完了しました。"}
            
          when 6 #寄り道するお店の種類を選択
            if @commute.search_area
              response =
                case @commute.search_area #寄り道地域設定済み
                when 1 #自宅付近
                  open(URI.encode ENV['G_SEARCH_URL'] + "query=#{data}&location=#{@commute.start_lat},#{@commute.start_lng}&radius=800&language=ja&key=" + ENV['G_KEY'])
                when 2 #職場付近
                  open(URI.encode ENV['G_SEARCH_URL'] + "query=#{data}&location=#{@commute.end_lat},#{@commute.end_lng}&radius=800&language=ja&key=" + ENV['G_KEY'])
                when 3 #中間地点付近（職場に最も近い中間地点）
                  open(URI.encode ENV['G_SEARCH_URL'] + "query=#{data}&location=#{@commute.via_place.last.via_lat},#{@commute.via_place.last.via_lng}&radius=1500&language=ja&key=" + ENV['G_KEY'])
                end
            elsif @commute.get_state.in?([1,2,3,4,5,6,7,8]) #寄り道地域は未設定だが、通勤場所は設定済み（職場付近で検索）
              response = open(URI.encode ENV['G_SEARCH_URL'] + "query=#{data}&location=#{@commute.end_lat},#{@commute.end_lng}&radius=800&language=ja&key=" + ENV['G_KEY'])
            else
              return client.reply_message(event['replyToken'], bad_msg(data))
            end
            store_info = JSON.parse(response.read, {symbolize_names: true})
            #配列にハッシュ化した店舗データを入れる（最大５件）
            box = []
            5.times do |n|
              box[n] = {}
              #写真、評価、クチコミが無い場合には、初期値を設定しておく
              store_info[:results][n].has_key?(:photos) ? photo = ENV['G_PHOTO_URL'] + "maxwidth=2000&photoreference=#{store_info[:results][n][:photos][0][:photo_reference]}&key=" + ENV['G_KEY'] : photo = "https://scdn.line-apps.com/n/channel_devcenter/img/fx/01_1_cafe.png"
              store_info[:results][n].has_key?(:rating) ? rating = store_info[:results][n][:rating] : rating = "未評価"
              store_info[:results][n].has_key?(:user_ratings_total) ? review = store_info[:results][n][:user_ratings_total] : review = "0"
              #経路用のGoogleMapURLをエンコード
              url = URI.encode ENV['G_STORE_URL'] + "&query=#{store_info[:results][n][:name]}&query_place_id=#{store_info[:results][n][:place_id]}"
              box[n] = {photo: photo, name: store_info[:results][n][:name], rating: rating,
                review: review, address: store_info[:results][n][:formatted_address], url: url, place_id: store_info[:results][n][:place_id]
              }
            end
            reply = change_msg(data, data: box)
          end
          client.reply_message(event['replyToken'], reply)
          
        when Line::Bot::Event::Follow
          User.create(id: event['source']['userId'])
          Commute.create(user_id: event['source']['userId'], setup_id: 14, first_setup: false)
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
    
    def get_commute_time(state)
      time = Time.parse(Time.now.to_s).to_i #現在時刻をAPIで使用するため、UNIX時間に変換
      case state
      when 1..4 #中間地点が設定済み
        w = ""
        via = ViaPlace.where(commute_id: @commute.id).order(:order)
        location = []
        via.each_with_index do |v, n|
          location[n] = {lat: v.via_lat, lng: v.via_lng}
        end
        location.each do |l|
          w = w + "via:#{l[:lat]},#{l[:lng]}|"
        end
        case state
        when 1
          response = open(ENV['G_DIRECTION_URL'] + "origin=#{@commute.start_lat},#{@commute.start_lng}&destination=#{@commute.end_lat},#{@commute.end_lng}
          &waypoints=#{w}&avoid=#{@commute.avoid}&departure_time=#{time}&traffic_model=#{@commute.mode}&language=ja&key=" + ENV['G_KEY'])
        when 2
          response = open(ENV['G_DIRECTION_URL'] + "origin=#{@commute.start_lat},#{@commute.start_lng}&destination=#{@commute.end_lat},#{@commute.end_lng}
          &waypoints=#{w}&avoid=#{@commute.avoid}&language=ja&key=" + ENV['G_KEY'])
        when 3
          response = open(ENV['G_DIRECTION_URL'] + "origin=#{@commute.start_lat},#{@commute.start_lng}&destination=#{@commute.end_lat},#{@commute.end_lng}
          &waypoints=#{w}&departure_time=#{time}&traffic_model=#{@commute.mode}&language=ja&key=" + ENV['G_KEY'])
        when 4
          response = open(ENV['G_DIRECTION_URL'] + "origin=#{@commute.start_lat},#{@commute.start_lng}&destination=#{@commute.end_lat},#{@commute.end_lng}
          &waypoints=#{w}&language=ja&key=" + ENV['G_KEY'])
        end
        
      when 5 #経路の制限、通勤モードが設定済み
        response = open(ENV['G_DIRECTION_URL'] + "origin=#{@commute.start_lat},#{@commute.start_lng}&destination=#{@commute.end_lat},#{@commute.end_lng}
        &avoid=#{@commute.avoid}&departure_time=#{time}&traffic_model=#{@commute.mode}&language=ja&key=" + ENV['G_KEY'])

      when 6 #経路の制限が設定済み
        response = open(ENV['G_DIRECTION_URL'] + "origin=#{@commute.start_lat},#{@commute.start_lng}&destination=#{@commute.end_lat},#{@commute.end_lng}
        &avoid=#{@commute.avoid}&language=ja&key=" + ENV['G_KEY'])

      when 7 #通勤モードが設定済み
        response = open(ENV['G_DIRECTION_URL'] + "origin=#{@commute.start_lat},#{@commute.start_lng}&destination=#{@commute.end_lat},#{@commute.end_lng}
        &departure_time=#{time}&traffic_model=#{@commute.mode}&language=ja&key=" + ENV['G_KEY'])
        
      when 8 #通勤設定のみ
        response = open(ENV['G_DIRECTION_URL'] + "origin=#{@commute.start_lat},#{@commute.start_lng}&destination=#{@commute.end_lat},#{@commute.end_lng}
        &language=ja&key=" + ENV['G_KEY'])
        
      end
      
      route_info = JSON.parse(response.read, {symbolize_names: true})
      if state.in?([1,3,5,7])
        route_info[:routes][0][:legs][0][:duration_in_traffic][:text]
      else
        route_info[:routes][0][:legs][0][:duration][:text]
      end
    end
end