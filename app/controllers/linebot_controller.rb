class LinebotController < ApplicationController
    require 'line/bot'  # gem 'line-bot-api'
    require "json" #jsonモジュールを利用
    require "open-uri" #Webサイトにアクセスできるようにする。
    require "date"
    
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
            message = event.message['text']
            user_id = event['source']['userId']
            user = User.find_by(line_id: user_id)
            case message
            when 'おはよう'
              message = change_msg(message)
              result_msg = message.join
              client.reply_message(event['replyToken'],
                [{type: "text", text: result_msg}, {type: "text", text: 'テスト'}]);
                
            when '通勤設定'
            　user.update_attributes(start_lat: nil,start_lng: nil,arrival_lat: nil,arrival_lng: nil)
              message = change_msg(message)
              client.reply_message(event['replyToken'], message);
              
            when '出発地点変更'
            　user.update_attributes(start_lat: nil,start_lng: nil)
              message = change_msg(message)
              client.reply_message(event['replyToken'], message);
              
            when '到着地点変更'
              user.update_attributes(arrival_lat: nil,arrival_lng: nil)
              message = change_msg(message)
              client.reply_message(event['replyToken'], message);
              
            when '通勤距離'
              response = open(ENV['G_URL'] + "origin=#{user.start_lat},#{user.start_lng}&destination=#{user.arrival_lat},#{user.arrival_lng}&key=#{ENV['G_API']}&language=ja")
              data = JSON.parse(response.read, {symbolize_names: true})
              time = data[:routes][0][:legs][0][:duration][:text]
              
              client.reply_message(event['replyToken'], {
                type: 'text',
                text: "出発地点から到着地点までの所要時間は、#{time}です。"
              });
              
            when 'ラーメン'
              url = URI.encode "#{ENV['G_PLACE_URL']}query=#{message}&location=#{user.start_lat},#{user.start_lng}&radius=10000&radius=1500&key=#{ENV['G_API']}"
              response = open(url)
              hash = JSON.parse(response.read, {symbolize_names: true})
              data = URI.encode "https://www.google.com/maps/search/?api=1&query=#{hash[:results][0][:name]}&query_place_id=#{hash[:results][0][:place_id]}"
              logger.debug(data)
              client.reply_message(event['replyToken'], {
                type: 'text',
                text: data
              });
              
            else
              message = {
              type: 'text',
              text: event.message['text']
              }
              client.reply_message(event['replyToken'], message)
            end
          when Line::Bot::Event::MessageType::Location  #位置情報が来た場合
            user_id = event['source']['userId']
            user = User.find_by(line_id: user_id)
            
            if user.start_lat.nil? && user.start_lng.nil?
              if user.arrival_lat.nil? && user.arrival_lng.nil?
                #スタート地点登録、更新
                user.update_attributes(start_lat: event.message['latitude'],start_lng: event.message['longitude'])
                client.reply_message(event['replyToken'], {
                  "type": "text",
                  "text": "到着地点の位置情報を教えてください！",
                  "quickReply": {
                    "items": [
                      
                      {
                        "type": "action",
                        "action": {
                          "type": "location",
                          "label": "位置情報"
                        }
                      }
                    ]
                  }
                })
              else
                user.update_attributes(start_lat: event.message['latitude'],start_lng: event.message['longitude'])
                client.reply_message(event['replyToken'], {
                  type: 'text',
                  text: "出発地点を緯度#{user.start_lat}、経度#{user.start_lng}に変更しました。"
                });
              end
                
                
            elsif user.arrival_lat.nil? && user.arrival_lng.nil?
              user.update_attributes(arrival_lat: event.message['latitude'],arrival_lng: event.message['longitude'])
              response = open(ENV['G_URL'] + "origin=#{user.start_lat},#{user.start_lng}&destination=#{user.arrival_lat},#{user.arrival_lng}&key=#{ENV['G_API']}&language=ja")
              data = JSON.parse(response.read, {symbolize_names: true})
              time = data[:routes][0][:legs][0][:duration][:text]
              
              client.reply_message(event['replyToken'], {
                type: 'text',
                text: "出発地点から到着地点までの所要時間は、#{time}です。"
              });
              
            end
          end
        when Line::Bot::Event::Follow
          response = event['source']['userId']
          User.create(line_id: response)
        when Line::Bot::Event::Unfollow
          response = event['source']['userId']
          User.find_by(line_id: response).destroy
        end
      }
      head :ok
    end
    
    # def send_destination(msg)
    #   if msg == '通勤設定'
    #     return true
    #   else
    #     false
    #   end
    # end
    
    # def send_msg(msg)
    #   if msg == 'おはよう'
    #     return true
    #   else
    #     false
    #   end
    # end

    def change_msg(msg)
      case msg
      when "おはよう"
        response = open(ENV['W_URL'] + "?q=Aichi&APPID=#{ENV['W_API']}")
        #JSONデータ(response)をハッシュ化
        data = JSON.parse(response.read, {symbolize_names: true})
        result = weather_text(data)
        return result
      when "通勤設定"
        result = {
          "type": "text",
          "text": "出発地点の位置情報を教えてください！",
          "quickReply": {
            "items": [
              
              {
                "type": "action",
                "action": {
                  "type": "location",
                  "label": "位置情報"
                }
              }
            ]
          }
        }
        return result
      when "出発地点変更"
        result = {
          "type": "text",
          "text": "出発地点の位置情報を教えてください！",
          "quickReply": {
            "items": [
              
              {
                "type": "action",
                "action": {
                  "type": "location",
                  "label": "位置情報"
                }
              }
            ]
          }
        }
        return result
      when "到着地点変更"
        result = {
          "type": "text",
          "text": "到着地点の位置情報を教えてください！",
          "quickReply": {
            "items": [
              
              {
                "type": "action",
                "action": {
                  "type": "location",
                  "label": "位置情報"
                }
              }
            ]
          }
        }
        return result
      when "テスト"
        result = {
          "type": "bubble",
          "hero": {
            "type": "image",
            "url": "https://scdn.line-apps.com/n/channel_devcenter/img/fx/01_1_cafe.png",
            "size": "full",
            "aspectRatio": "20:13",
            "aspectMode": "cover",
            "action": {
              "type": "uri",
              "uri": "http://linecorp.com/"
            }
          },
          "body": {
            "type": "box",
            "layout": "vertical",
            "contents": [
              {
                "type": "text",
                "text": "Brown Cafe",
                "weight": "bold",
                "size": "xl"
              },
              {
                "type": "box",
                "layout": "baseline",
                "margin": "md",
                "contents": [
                  {
                    "type": "icon",
                    "size": "sm",
                    "url": "https://scdn.line-apps.com/n/channel_devcenter/img/fx/review_gold_star_28.png"
                  },
                  {
                    "type": "icon",
                    "size": "sm",
                    "url": "https://scdn.line-apps.com/n/channel_devcenter/img/fx/review_gold_star_28.png"
                  },
                  {
                    "type": "icon",
                    "size": "sm",
                    "url": "https://scdn.line-apps.com/n/channel_devcenter/img/fx/review_gold_star_28.png"
                  },
                  {
                    "type": "icon",
                    "size": "sm",
                    "url": "https://scdn.line-apps.com/n/channel_devcenter/img/fx/review_gold_star_28.png"
                  },
                  {
                    "type": "icon",
                    "size": "sm",
                    "url": "https://scdn.line-apps.com/n/channel_devcenter/img/fx/review_gray_star_28.png"
                  },
                  {
                    "type": "text",
                    "text": "4.0",
                    "size": "sm",
                    "color": "#999999",
                    "margin": "md",
                    "flex": 0
                  }
                ]
              },
              {
                "type": "box",
                "layout": "vertical",
                "margin": "lg",
                "spacing": "sm",
                "contents": [
                  {
                    "type": "box",
                    "layout": "baseline",
                    "spacing": "sm",
                    "contents": [
                      {
                        "type": "text",
                        "text": "Place",
                        "color": "#aaaaaa",
                        "size": "sm",
                        "flex": 1
                      },
                      {
                        "type": "text",
                        "text": "Miraina Tower, 4-1-6 Shinjuku, Tokyo",
                        "wrap": true,
                        "color": "#666666",
                        "size": "sm",
                        "flex": 5
                      }
                    ]
                  },
                  {
                    "type": "box",
                    "layout": "baseline",
                    "spacing": "sm",
                    "contents": [
                      {
                        "type": "text",
                        "text": "Time",
                        "color": "#aaaaaa",
                        "size": "sm",
                        "flex": 1
                      },
                      {
                        "type": "text",
                        "text": "10:00 - 23:00",
                        "wrap": true,
                        "color": "#666666",
                        "size": "sm",
                        "flex": 5
                      }
                    ]
                  }
                ]
              }
            ]
          },
          "footer": {
            "type": "box",
            "layout": "vertical",
            "spacing": "sm",
            "contents": [
              {
                "type": "button",
                "style": "link",
                "height": "sm",
                "action": {
                  "type": "uri",
                  "label": "CALL",
                  "uri": "https://linecorp.com"
                }
              },
              {
                "type": "button",
                "style": "link",
                "height": "sm",
                "action": {
                  "type": "uri",
                  "label": "WEBSITE",
                  "uri": "https://linecorp.com"
                }
              },
              {
                "type": "spacer",
                "size": "sm"
              }
            ],
            "flex": 0
          }
        }
        return result
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
    
    def user_params
      params.require(:user).permit(:line_id)
    end

    def client
      @client ||= Line::Bot::Client.new { |config|
        config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
        config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
      }
    end
    
end