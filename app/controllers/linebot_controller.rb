class LinebotController < ApplicationController
    require 'line/bot'  # gem 'line-bot-api'
    require "json" #jsonモジュールを利用
    require "open-uri" #Webサイトにアクセスできるようにする。
    require "date" #TimeZone
    include BaseRequest
    include BadRequest
    
    # callbackアクションのCSRFトークン認証を無効
    protect_from_forgery :except => [:callback]

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
            commute = Commute.find_by(user_id: event['source']['userId'])
            message = event.message['text']
            case message
            when 'おはよう'
              message = change_msg(message)
              reply = message.join
              client.reply_message(event['replyToken'],
                [{type: "text", text: reply}, {type: "text", text: '二言返信テスト'}])
                
            when '通勤設定'
              commute.update_attributes(start_lat: nil,start_lng: nil,end_lat: nil,end_lng: nil)
              ViaPlace.where(commute_id: commute.id).destroy_all
              reply = change_msg(message)
              client.reply_message(event['replyToken'], reply)
            
            when '通勤モード'
              reply = change_msg(message,commute)
              client.reply_message(event['replyToken'], reply)
              
            when '出発地点変更'
              commute.update_attributes(start_lat: nil,start_lng: nil)
              reply = change_msg(message)
              client.reply_message(event['replyToken'], reply)
              
            when '到着地点変更'
              commute.update_attributes(end_lat: nil,end_lng: nil)
              reply = change_msg(message)
              client.reply_message(event['replyToken'], reply)
            
            when '中間地点登録'
              state = commute.get_state
              logger.debug(state)
              case state
              when 0,1
                reply = change_msg(message)
              when 2,3,4
                reply = bad_msg(message)#出発、到着地が登録されていない場合
              end
              client.reply_message(event['replyToken'], reply)
              
            when '中間地点削除'
              if commute.via_place.first
                ViaPlace.where(commute_id: commute.id).destroy_all
                reply = change_msg(message)
              else
                reply = bad_msg(message)
              end
              client.reply_message(event['replyToken'], reply)
              
            when '制限'
              state = commute.get_state
              reply = change_msg(message)
              if commute.avoid
                commute.update_attributes(avoid: nil)
                reply = [reply,{type: 'text',text: "選択済みの設定をリセットしました。"}]
              end
              client.reply_message(event['replyToken'], reply)
              
            when '通勤時間'
              state = commute.get_state
              logger.debug(state)
              return client.reply_message(event['replyToken'], bad_msg(message)) if state.in?([2,3,4])
              time = Time.parse(Time.now.to_s).to_i #現在時刻をAPIで使用するため、UNIX時間に変換
              if commute.mode
                case state
                when 0
                  w = ""
                  via = ViaPlace.where(commute_id: commute.id).order(:order)
                  location = Array.new
                  via.each_with_index do |v,n|
                    location[n] = {lat: v.via_lat, lng: v.via_lng}
                  end
                  location.each do |l|
                    w = w + "via:#{l[:lat]},#{l[:lng]}|"
                  end
                  response = open(ENV['G_DIRECTION_URL'] + "origin=#{commute.start_lat},#{commute.start_lng}&destination=#{commute.end_lat},#{commute.end_lng}
                  &waypoints=#{w}&departure_time=#{time}&traffic_model=#{commute.mode}&language=ja&key=" + ENV['G_KEY'])
                when 1
                  response = open(ENV['G_DIRECTION_URL'] + "origin=#{commute.start_lat},#{commute.start_lng}&destination=#{commute.end_lat},#{commute.end_lng}
                  &departure_time=#{time}&traffic_model=#{commute.mode}&language=ja&key=" + ENV['G_KEY'])
                end
                data = JSON.parse(response.read, {symbolize_names: true})
                reply = {type: "text",text: "#{data[:routes][0][:legs][0][:duration_in_traffic][:text]}"}
              else
                response = open(ENV['G_DIRECTION_URL'] + "origin=#{commute.start_lat},#{commute.start_lng}&destination=#{commute.end_lat},#{commute.end_lng}
                &language=ja&key=" + ENV['G_KEY'])
                data = JSON.parse(response.read, {symbolize_names: true})
                reply = {type: "text",text: "#{data[:routes][0][:legs][0][:duration][:text]}"}
              end
              client.reply_message(event['replyToken'], reply)
              
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
              count = data.count
              reply = change_msg(message,data,count)
              client.reply_message(event['replyToken'], reply)
              
            when 'ラーメン','カフェ','コンビニ','ファミレス','焼肉'
              #検索ワードの周辺店舗を検索
              state = commute.get_state
              case state
              when 0
                response = open(URI.encode ENV['G_SEARCH_URL'] + "query=#{message}&location=#{commute.via_place.first.via_lat},#{commute.via_place.first.via_lng}&radius=1500&language=ja&key=" + ENV['G_KEY'])
              when 1
                response = open(URI.encode ENV['G_SEARCH_URL'] + "query=#{message}&location=#{commute.end_lat},#{commute.end_lng}&radius=1000&language=ja&key=" + ENV['G_KEY'])
              else
                return client.reply_message(event['replyToken'], bad_msg(message))
              end
              hash = JSON.parse(response.read, {symbolize_names: true})
              #配列にハッシュ化した店舗データを入れる（最大５件）
              data = Array.new
              5.times do |n|
                data[n] = Hash.new
                #写真、評価、クチコミが無いとフロント部分が崩れるので存在を確認
                hash[:results][n].has_key?(:photos) ? photo = ENV['G_PHOTO_URL'] + "maxwidth=2000&photoreference=#{hash[:results][n][:photos][0][:photo_reference]}&key=" + ENV['G_KEY'] : photo = "https://scdn.line-apps.com/n/channel_devcenter/img/fx/01_1_cafe.png"
                hash[:results][n].has_key?(:rating) ? rating = hash[:results][n][:rating] : rating = "未評価"
                hash[:results][n].has_key?(:user_ratings_total) ? review = hash[:results][n][:user_ratings_total] : review = "0"
                #経路用のGoogleMapURLをエンコード
                url = URI.encode ENV['G_STORE_URL'] + "&query=#{hash[:results][n][:name]}&query_place_id=#{hash[:results][n][:place_id]}"
                data[n] = {photo: photo, name: hash[:results][n][:name], rating: rating,
                  review: review, address: hash[:results][n][:formatted_address], url: url, place_id: hash[:results][n][:place_id]
                }
              end
              client.reply_message(event['replyToken'], change_msg(message,data))
            
            when 'コマンド一覧'
              client.reply_message(event['replyToken'], change_msg(message))
              
            when 'テスト'
              #modeリセット
              # commute.update_attributes(mode: nil)
              # client.reply_message(event['replyToken'], {
              #   type: 'text',
              #   text: "modeをリセットしました。"
              # })
              
              #avoid確認
              client.reply_message(event['replyToken'], {
                type: 'text',
                text: commute.avoid
              })
            end
            
          when Line::Bot::Event::MessageType::Location #位置情報が来た場合
            commute = Commute.find_by(user_id: event['source']['userId'])
            state = commute.get_state
            case state
            when 0,1 #中間地点登録
              count = ViaPlace.where(commute_id: commute.id).count + 1
              ViaPlace.create(commute_id: commute.id, via_lat: event.message['latitude'], via_lng: event.message['longitude'], order: count)
              client.reply_message(event['replyToken'], {
                type: 'text',
                text: "中間地点を登録しました。"
              })
            when 2 #到着地変更
              commute.update_attributes(end_lat: event.message['latitude'], end_lng: event.message['longitude'])
              response = open(ENV['G_DIRECTION_URL'] + "origin=#{commute.start_lat},#{commute.start_lng}&destination=#{commute.end_lat},#{commute.end_lng}&language=ja&key=" + ENV['G_KEY'])
              data = JSON.parse(response.read, {symbolize_names: true})
              result = data[:routes][0][:legs][0][:duration][:text]
              if commute.mode
                reply = {type: 'text',text: "出発地点から到着地点までの所要時間は、#{result}です。"}
              else
                reply = [{type: 'text',text: "出発地点から到着地点までの所要時間は、#{result}です。"},
                  {type: 'text',text: "「通勤モード」と送信すると、よりあなたに合った通勤スタイルを選択できます。"}
                ]
              end
              client.reply_message(event['replyToken'], reply)
            when 3 #出発地のみ変更
              commute.update_attributes(start_lat: event.message['latitude'],start_lng: event.message['longitude'])
              client.reply_message(event['replyToken'], {
                type: 'text',
                text: "出発地点を変更しました。"
              })
            when 4 #初期設定or全部変更
              commute.update_attributes(start_lat: event.message['latitude'],start_lng: event.message['longitude'])
              reply = change_msg('全設定')
              client.reply_message(event['replyToken'], reply)
            else #エラー
              client.reply_message(event['replyToken'], {
                type: 'text',
                text: "そのコマンドは存在しません。"
              })
            end
          end
          
        when Line::Bot::Event::Postback
          user = User.find_by(id: event['source']['userId'])
          data = event['postback']['data']
          code = data.slice!(-1).to_i
          logger.debug(data)
          logger.debug(code)
          case code
          when 1 #通勤モード変更
            user.commute.update_attributes(mode: data)
            client.reply_message(event['replyToken'], {
                type: 'text',
                text: "通勤モードを設定しました。"
            })
          when 2 #寄り道機能のお気に入り登録
            if Favorite.where(user_id: user.id).count < 5
              Favorite.create(user_id: user.id, place_id: data)
              client.reply_message(event['replyToken'], {
                  type: 'text',
                  text: "お気に入りに登録しました。"
              })
            else
              client.reply_message(event['replyToken'], [{
                type: 'text',
                text: "登録に失敗しました。\nお気に入りは最大5件までです。"},{
                type: 'text',
                text: "お気に入りの店舗を減らしてからもう一度お試しください。\n「お気に入り」と入力すると、現在のお気に入り店舗一覧が表示できます。"}
              ])
            end
          when 3 #お気に入りの解除
            Favorite.find_by(user_id: user.id,place_id: data).destroy
            client.reply_message(event['replyToken'], {
                type: 'text',
                text: "お気に入りを解除しました。"
            })
          when 4 #通勤経路の制限
            avoid = user.commute.avoid
            return client.reply_message(event['replyToken'], bad_msg('avoid')) if avoid == "tolls|highways|ferries"
            reply = get_reply(user, data, avoid)
            now = avoid_now(user.commute.avoid)
            client.reply_message(event['replyToken'], [reply,{type: 'text',text: "現在は、#{now}が設定されています。"}])
          end
        when Line::Bot::Event::Follow
          User.create(id: event['source']['userId'])
          Commute.create(user_id: event['source']['userId'])
        when Line::Bot::Event::Unfollow
          User.find_by(id: event['source']['userId']).destroy
        else
          client.reply_message(event['replyToken'], {type: 'text', text: event.message['そのコマンドは存在しません。']})
        end
      }
      head :ok
    end
    
    def get_reply(user, data, avoid)
      if avoid #中身があるか確認（初めてかどうか）
        if data == "tolls|highways|ferries" #全て使用しないが来た場合
          user.commute.update_attributes(avoid: data)
          {type: 'text',text: "設定しました。"}
        end
        if avoid.include?(data) #制限されている数が２個以下
          add = change_avoid(avoid, data)
          user.commute.update_attributes(avoid: add)
          {type: 'text',text: "設定を追加しました。"}
        else
          #選択されたものが制限されていない場合
          {type: 'text',text: "選択されたものは設定済みです。"}
        end
      else
        #初めて来たときの処理
        if data == "tolls|highways|ferries"
          add = "tolls|highways|ferries"
          text = "全て使用しない"
        else
          case data
          when "tolls"
            add = "highways|ferries"
            text = "有料道路"
          when "highways"
            add = "tolls|ferries"
            text = "高速道路"
          when "ferries"
            add = "tolls|highways"
            text = "フェリー"
          end
        end
        user.commute.update_attributes(avoid: add)
        {type: 'text',text: "#{text}を設定しました。"}
      end
    end
    
    def change_avoid(avoid, data)
      case data
      when "tolls"
        if avoid.include?("highways")
          "highways"
        elsif avoid.include?("ferries")
          "ferries"
        end
      when "highways"
        if avoid.include?("tolls")
          "tolls"
        elsif avoid.include?("ferries")
          "ferries"
        end
      when "ferries"
        if avoid.include?("tolls")
          "tolls"
        elsif avoid.include?("highways")
          "highways"
        end
      end
    end
    
    def avoid_now(a)
      case a
      when "tolls|highways|ferries"
        "全て使用しない"
      when "tolls|highways"
        "フェリー"
      when "tolls|ferries"
        "高速道路"
      when "highways|ferries"
        "有料道路"
      when "tolls"
        "高速道路、フェリー"
      when "highways"
        "有料道路、フェリー"
      when "ferries"
        "有料道路、高速道路"
      else
        "全て"
      end
    end
  
    
    
    def weather_text(weather_data)
      item = weather_data[:list]
      result = Array.new
      forecastCityname = weather_data[:city][:name]
      (0..7).each do |i|
        forecastDatetime = item[i][:dt_txt]
        logger.debug(forecastDatetime)
        forecasttemp = (item[i][:main][:temp] - 273.15).round(1)
        weather_id = item[i][:weather][0][:id]
        weather = get_weather(weather_id)
        # weather_icon = item[i][:weather][i][:icon]
        result[i] = "#{forecastCityname}の天気をお知らせします。\n#{forecastDatetime}の天気は#{weather}\n温度は#{forecasttemp}\n"
      end
      return result
    end
    
    def get_weather(weather_id)
      logger.debug(weather_id)
      case weather_id
      when 200, 201, 202, 210, 211, 212, 221, 230, 231, 232, 
        300, 301, 302, 310, 311, 312, 313, 314, 321, 
        500, 501, 502, 503, 504, 511, 520, 521, 522, 523 ,531 then
        weather = '雨'
        return weather
      when 601, 602, 611, 612, 615, 616, 620, 621, 622 then
        weather = '雪'
        return weather
      when 701, 711, 721, 731, 741, 751, 761, 762, 771, 781 then
        weather = '異常気象'
        return weather
      when 800 then
        weather = '晴れ'
        return weather
      when 801, 802, 803, 804 then
        weather = '曇り'
        return weather
      else
        weather = '不明'
        return weather
      end
    end
    
    private

    def client
      @client ||= Line::Bot::Client.new { |config|
        config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
        config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
      }
    end
    
end