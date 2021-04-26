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
              start_response = open(ENV['W_URL'] + "?zip=#{commute.start_address},jp&units=metric&lang=ja&cnt=6&APPID=" + ENV['W_KEY'])
              end_response = open(ENV['W_URL'] + "?zip=#{commute.end_address},jp&units=metric&lang=ja&cnt=6&APPID=" + ENV['W_KEY'])
              #JSONデータをハッシュ化
              data[0] = JSON.parse(start_response.read, {symbolize_names: true})
              data[1] = JSON.parse(end_response.read, {symbolize_names: true})
              reply = change_msg(message, data: data)

            when '通勤設定'
              reply = change_msg(message, data: commute.get_state)
              commute.update_attributes(start_lat: nil,start_lng: nil,end_lat: nil,end_lng: nil)
              commute.via_place.destroy_all

            when '通勤モード'
              reply = commute.start_lat && commute.end_lat ? change_msg(message) : bad_msg(message)

            when '出発地点変更'
              reply = change_msg(message, data: commute.get_state)
              commute.update_attributes(start_lat: nil,start_lng: nil)
              commute.via_place.destroy_all

            when '到着地点変更'
              reply = change_msg(message, data: commute.get_state)
              commute.update_attributes(end_lat: nil,end_lng: nil)
              commute.via_place.destroy_all

            when '中間地点登録'
              state = commute.get_state
              reply = state.in?([0, 1]) ? change_msg(message) : bad_msg(message, data: state)

            when '中間地点削除'
              reply =
                if commute.via_place.first
                  ViaPlace.where(commute_id: commute.id).destroy_all
                  change_msg(message)
                else
                  bad_msg(message)
                end

            when '経路の制限'
              state = commute.get_state
              commute.update_attributes(avoid: "tolls|highways|ferries")
              reply = change_msg(message, data: commute)
              
            when '通勤時間'
              state = commute.get_state
              return client.reply_message(event['replyToken'], bad_msg(message)) if state.in?([2,3,4])
              time = Time.parse(Time.now.to_s).to_i #現在時刻をAPIで使用するため、UNIX時間に変換
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

            when '寄り道地域'
              state = commute.get_state
              reply = state.in?([0, 1]) ? change_msg(message, data: state) : bad_msg(message)

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

            when 'ラーメン','カフェ','コンビニ','ファミレス','焼肉'
              if commute.search_area
                response =
                  case commute.search_area #寄り道地域設定済み
                  when 1 #自宅付近
                    open(URI.encode ENV['G_SEARCH_URL'] + "query=#{message}&location=#{commute.start_lat},#{commute.start_lng}&radius=800&language=ja&key=" + ENV['G_KEY'])
                  when 2 #職場付近
                    open(URI.encode ENV['G_SEARCH_URL'] + "query=#{message}&location=#{commute.end_lat},#{commute.end_lng}&radius=800&language=ja&key=" + ENV['G_KEY'])
                  when 3 #中間地点付近（職場に最も近い中間地点）
                    open(URI.encode ENV['G_SEARCH_URL'] + "query=#{message}&location=#{commute.via_place.last.via_lat},#{commute.via_place.last.via_lng}&radius=1500&language=ja&key=" + ENV['G_KEY'])
                  end
              elsif commute.start_lat && commute.end_lat #寄り道地域は未設定だが、通勤場所は設定済み（職場付近で検索）
                response = open(URI.encode ENV['G_SEARCH_URL'] + "query=#{message}&location=#{commute.end_lat},#{commute.end_lng}&radius=800&language=ja&key=" + ENV['G_KEY'])
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
              reply = change_msg(message, data: data)
            
            when 'ヘルプ'
              reply = change_msg(message)
              
            when 'テスト'
              # commute.update_attributes(start_lat: nil,start_lng: nil,end_lat: nil,end_lng: nil, avoid: nil, mode: nil)
              # commute.via_place.destroy_all
              # client.reply_message(event['replyToken'], {type: 'text', text: commute.setting.content})
              logger.debug(Setting.find(1).content)
              client.reply_message(event['replyToken'], 
                [
                  {type: 'text', text: "test"},
                  Setting.find(1).content
                ]
              )
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
              reply =
                if commute.avoid_first == false && commute.mode
                  {type: 'text', text: "#{count}つ目の中間地点を登録しました。"}
                elsif commute.avoid_first
                  {type: 'text', text: "#{count}つ目の中間地点を登録しました。",
                  "quickReply": {
                      "items": [
                        {
                          "type": "action",
                          "action": {
                            "type": "message",
                            "label": "次の設定へ",
                            "text": "経路の制限"
                          }
                        }
                      ]
                    }
                  }
                else
                  {type: 'text', text: "#{count}つ目の中間地点を登録しました。",
                  "quickReply": {
                      "items": [
                        {
                          "type": "action",
                          "action": {
                            "type": "message",
                            "label": "次の設定へ",
                            "text": "通勤モード"
                          }
                        }
                      ]
                    }
                  }
                end
              client.reply_message(event['replyToken'], reply)
            when 2 #到着地変更
              commute.update_attributes(end_lat: event.message['latitude'], end_lng: event.message['longitude'])
              response = open(ENV['G_DIRECTION_URL'] + "origin=#{commute.start_lat},#{commute.start_lng}&destination=#{commute.end_lat},#{commute.end_lng}&language=ja&key=" + ENV['G_KEY'])
              data = JSON.parse(response.read, {symbolize_names: true})
              st = data[:routes][0][:legs][0][:start_address].slice(4..11)
              en = data[:routes][0][:legs][0][:end_address].slice(4..11)
              commute.update_attributes(start_address: st, end_address: en)
              result = data[:routes][0][:legs][0][:duration][:text]
              if commute.avoid_first
                if commute.via_place.first
                  if commute.mode
                    reply = {type: 'text',text: "出発地点から到着地点までの所要時間は、#{result}です。"}
                  else
                    reply = 
                      {
                        type: 'text',text: "出発地点から到着地点までの所要時間は、#{result}です。",
                        "quickReply": {
                          "items": [
                            {
                              "type": "action",
                              "action": {
                                "type": "message",
                                "label": "次の設定へ",
                                "text": "通勤モード"
                              }
                            }
                          ]
                        }
                      }
                  end
                else
                  reply =
                    {
                      type: 'text',text: "出発地点から到着地点までの所要時間は、#{result}です。",
                      "quickReply": {
                        "items": [
                          {
                            "type": "action",
                            "action": {
                              "type": "message",
                              "label": "次の設定へ",
                              "text": "中間地点登録"
                            }
                          }
                        ]
                      }
                    }
                end
              else
                reply =
                    {
                      type: 'text',text: "出発地点から到着地点までの所要時間は、#{result}です。",
                      "quickReply": {
                        "items": [
                          {
                            "type": "action",
                            "action": {
                              "type": "message",
                              "label": "次の設定へ",
                              "text": "経路の制限"
                            }
                          }
                        ]
                      }
                    }
              end
            when 3 #出発地のみ変更
              commute.update_attributes(start_lat: event.message['latitude'], start_lng: event.message['longitude'])
              response = open(ENV['G_DIRECTION_URL'] + "origin=#{commute.start_lat},#{commute.start_lng}&destination=#{commute.end_lat},#{commute.end_lng}&language=ja&key=" + ENV['G_KEY'])
              data = JSON.parse(response.read, {symbolize_names: true})
              commute.update_attributes(start_address: data[:routes][0][:legs][0][:start_address].slice(4..11))
              result = data[:routes][0][:legs][0][:duration][:text]
              if commute.mode
                reply = {type: 'text',text: "出発地点から到着地点までの所要時間は、#{result}です。"}
              else
                reply = [{type: 'text',text: "出発地点から到着地点までの所要時間は、#{result}です。"},
                  {type: 'text',text: "「通勤モード」と送信すると、よりあなたに合った通勤スタイルを選択できます。"}
                ]
              end
            when 4 #初期設定or全部変更
              commute.update_attributes(start_lat: event.message['latitude'], start_lng: event.message['longitude'])
              reply = change_msg('通勤設定2')
            else #エラー
              reply = {type: 'text', text: "そのコマンドは存在しません。"}
            end
            client.reply_message(event['replyToken'], reply)
          end
          
        when Line::Bot::Event::Postback
          user = User.find_by(id: event['source']['userId'])
          commute = user.commute
          data = event['postback']['data']
          code = data.slice!(-1).to_i
          case code
          when 1 #通勤モード変更
            commute.update_attributes(mode: data)
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
            if commute.avoid.include?(data)
              commute.avoid.slice!(data)
            else
              return client.reply_message(event['replyToken'], bad_msg('avoid'))
            end
            commute.avoid.slice!(0) if commute.avoid[0] == "|"
            commute.avoid.slice!(-1) if commute.avoid[-1] == "|"
            commute.avoid.slice!(7) if commute.avoid[7] == "|"
            commute.save
            logger.debug(commute.avoid)
            reply = change_msg('avoid', data: commute)
            client.reply_message(event['replyToken'], reply)
            
          when 5 #寄り道機能の検索位置設定
            commute.update_attributes(search_area: data.to_i)
            client.reply_message(event['replyToken'], {type: 'text',text: "検索エリアの設定が完了しました。"})
          end
          
        when Line::Bot::Event::Follow
          User.create(id: event['source']['userId'])
          Commute.create(user_id: event['source']['userId'], avoid: "tolls|highways|ferries", setting_id: 1)
          reply = change_msg("follow")
          client.reply_message(event['replyToken'], reply)
        when Line::Bot::Event::Unfollow
          User.find_by(id: event['source']['userId']).destroy
        else
          client.reply_message(event['replyToken'], {type: 'text', text: 'そのコマンドは存在しません。'})
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