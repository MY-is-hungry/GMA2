class LinebotController < ApplicationController
    require 'line/bot'  # gem 'line-bot-api'
    require "json" #jsonモジュールを利用
    require "open-uri" #Webサイトにアクセスできるようにする。
    require "date" #TimeZone
    include JsonRequest
    
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
              commute.update_attributes(start_lat: nil,start_lng: nil,arrival_lat: nil,arrival_lng: nil)
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
              commute.update_attributes(arrival_lat: nil,arrival_lng: nil)
              reply = change_msg(message)
              client.reply_message(event['replyToken'], reply)
              
            when '通勤時間'
              if commute.start_lat && commute.arrival_lat
                #現在時刻をAPIで使用するため、UNIX時間に変換
                time = Time.parse(Time.now.to_s).to_i
                response = open(ENV['G_URL'] + "origin=#{commute.start_lat},#{commute.start_lng}&destination=#{commute.arrival_lat},#{commute.arrival_lng}
                &departure_time=#{time}&traffic_model=#{commute.mode}&language=ja&key=" + ENV['G_KEY'])
                data = JSON.parse(response.read, {symbolize_names: true})
                result = data[:routes][0][:legs][0][:duration_in_traffic][:text]
                if commute.mode.nil?
                  client.reply_message(event['replyToken'], [
                    {type: 'text',text: "出発地点から到着地点までの所要時間は、#{result}です。"},
                    {type: 'text',text: "「通勤モード」と送信すると、よりあなたに合った通勤スタイルを選択できます。"}
                  ])
                else
                  client.reply_message(event['replyToken'], {
                    type: 'text',
                    text: "出発地点から到着地点までの所要時間は、#{result}です。"
                  })
                end
              else
                client.reply_message(event['replyToken'], [{
                  type: 'text',
                  text: "出発地点か、到着地点が設定されていません。"},{
                  type: 'text',
                  text: "「通勤設定」と送信すると、設定できます。"
                  }])
              end
              
            when 'お気に入り'
              fav_id = Favorite.where(user_id: commute.user_id).pluck(:place_id)
              array = Array.new
              m = 0
              fav_id.each do |f|
                # url = URI.encode "https://maps.googleapis.com/maps/api/place/details/json?place_id=#{fav_id[n]}&language=ja&key=" + ENV['G_KEY']
                url = URI.encode "https://maps.googleapis.com/maps/api/place/details/json?place_id=#{f}&language=ja&key=" + ENV['G_KEY']
                response = open(url)
                array[m] = JSON.parse(response.read)
                logger.debug(array[m])
                m += 1
              end
              data = Array.new
              n = 0
              array.each do |a|
                data[n] = Hash.new
                #写真、評価、クチコミは無いとフロントが崩れるのでチェックする
                a[n][:results].has_key?(:photos) ? photo = ENV['G_PHOTO_URL'] + "maxwidth=2000&photoreference=#{a[n][:results][:photos][0][:photo_reference]}&key=" + ENV['G_KEY'] : photo = "https://scdn.line-apps.com/n/channel_devcenter/img/fx/01_1_cafe.png"
                # a[n][:results][0].has_key?(:rating) ? rating = a[n][:results][0][:rating] : rating = "未評価"
                # a[n][:results][0].has_key?(:user_ratings_total) ? review = a[n][:results][0][:user_ratings_total] : review = "0"
                #経路用のGoogleMapURLをエンード
                url = URI.encode ENV['G_STORE_URL'] + "&query=#{array[n][:results][0][:name]}&query_place_id=#{a[n][:results][0][:place_id]}"
                data[n] = {photo: photo, name: a[n][:results][0][:name], rating: rating,
                  review: review, address: a[n][:results][0][:formatted_address], url: url
                }
                n += 1
              end
              reply = change_msg(message,data)
              client.reply_message(event['replyToken'], reply)
              
            when 'ラーメン','ラーメン屋','らーめん','カフェ','喫茶店','コンビニ','ファミレス','焼肉','焼き肉','にく'
              #検索ワードの周辺店舗を検索
              url = URI.encode ENV['G_SEARCH_URL'] + "query=#{message}&location=#{commute.arrival_lat},#{commute.arrival_lng}&radius=1000&language=ja&key=" + ENV['G_KEY']
              response = open(url)
              hash = JSON.parse(response.read, {symbolize_names: true})
              #配列にハッシュ化した店舗データを入れる（最大５件）
              data = Array.new
              (0..4).each do |n|
                data[n] = Hash.new
                #写真、評価、クチコミは無いとフロントが崩れるのでチェックする
                hash[:results][n].has_key?(:photos) ? photo = ENV['G_PHOTO_URL'] + "maxwidth=2000&photoreference=#{hash[:results][n][:photos][0][:photo_reference]}&key=" + ENV['G_KEY'] : photo = "https://scdn.line-apps.com/n/channel_devcenter/img/fx/01_1_cafe.png"
                hash[:results][n].has_key?(:rating) ? rating = hash[:results][n][:rating] : rating = "未評価"
                hash[:results][n].has_key?(:user_ratings_total) ? review = hash[:results][n][:user_ratings_total] : review = "0"
                #経路用のGoogleMapURLをエンード
                url = URI.encode ENV['G_STORE_URL'] + "&query=#{hash[:results][n][:name]}&query_place_id=#{hash[:results][n][:place_id]}"
                data[n] = {photo: photo, name: hash[:results][n][:name], rating: rating,
                  review: review, address: hash[:results][n][:formatted_address], url: url, place_id: hash[:results][n][:place_id]
                }
              end
              reply = change_msg(message,data)
              client.reply_message(event['replyToken'], reply)
              
            when 'テスト'
              commute.update_attributes(mode: nil)
              client.reply_message(event['replyToken'], {
                type: 'text',
                text: "modeをリセットしました。"
              })
            end
            
          when Line::Bot::Event::MessageType::Location #位置情報が来た場合
            commute = Commute.find_by(user_id: event['source']['userId'])
            state = commute.get_state
            case state
            when 1 #到着地変更
              commute.update_attributes(arrival_lat: event.message['latitude'],arrival_lng: event.message['longitude'])
              response = open(ENV['G_URL'] + "origin=#{commute.start_lat},#{commute.start_lng}&destination=#{commute.arrival_lat},#{commute.arrival_lng}&language=ja&key=" + ENV['G_KEY'])
              data = JSON.parse(response.read, {symbolize_names: true})
              result = data[:routes][0][:legs][0][:duration][:text]
              if commute.mode
                client.reply_message(event['replyToken'], {
                  type: 'text',
                  text: "出発地点から到着地点までの所要時間は、#{result}です。"
                })
              else
                client.reply_message(event['replyToken'], [
                  {type: 'text',text: "出発地点から到着地点までの所要時間は、#{result}です。"},
                  {type: 'text',text: "「通勤モード」と送信すると、よりあなたに合った通勤スタイルを選択できます。"}
                ])
              end
            when 2 #出発地のみ変更
              commute.update_attributes(start_lat: event.message['latitude'],start_lng: event.message['longitude'])
              client.reply_message(event['replyToken'], {
                type: 'text',
                text: "出発地点を変更しました。"
              })
            when 3 #初期設定or全部変更
              commute.update_attributes(start_lat: event.message['latitude'],start_lng: event.message['longitude'])
              reply = change_msg('全設定')
              client.reply_message(event['replyToken'], reply)
            when 0 #エラー
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