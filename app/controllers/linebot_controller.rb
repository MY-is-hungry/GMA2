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
                [{type: "text", text: result_msg}, {type: "text", text: 'テスト'}])
                
            when '通勤設定'
            　user.update_attributes(start_lat: nil,start_lng: nil,arrival_lat: nil,arrival_lng: nil)
              message = change_msg(message)
              client.reply_message(event['replyToken'], message)
              
            when '出発地点変更'
            　user.update_attributes(start_lat: nil,start_lng: nil)
              message = change_msg(message)
              client.reply_message(event['replyToken'], message)
              
            when '到着地点変更'
              user.update_attributes(arrival_lat: nil,arrival_lng: nil)
              message = change_msg(message)
              client.reply_message(event['replyToken'], message)
              
            when '通勤距離'
              response = open(ENV['G_URL'] + "origin=#{user.start_lat},#{user.start_lng}&destination=#{user.arrival_lat},#{user.arrival_lng}&language=ja&key=" + ENV['G_KEY'])
              data = JSON.parse(response.read, {symbolize_names: true})
              time = data[:routes][0][:legs][0][:duration][:text]
              
              client.reply_message(event['replyToken'], {
                type: 'text',
                text: "出発地点から到着地点までの所要時間は、#{time}です。"
              })
              
            when 'ラーメン','カフェ'
              #検索ワードの周辺店舗を検索
              url = URI.encode ENV['G_SEARCH_URL'] + "query=#{message}&location=#{user.start_lat},#{user.start_lng}&radius=1500&language=ja&key=" + ENV['G_KEY']
              response = open(url)
              hash = JSON.parse(response.read, {symbolize_names: true})
              logger.debug(hash)
              #配列にハッシュ化した店舗データを入れる（最大５件）
              data = Array.new
              (0..4).each do |n|
                data[n] = Hash.new
                #店の写真をPlaces Photoから取り出す
                if hash[:results][n][:photos][0].has_key?(:photo_reference)
                  photo = "assets/images/no_image.png"
                else
                  photo = ENV['G_PHOTO_URL'] + "maxwidth=3000&photoreference=#{hash[:results][n][:photos][0][:photo_reference]}&key=" + ENV['G_KEY']
                end
                logger.debug(photo)
                #経路用のGoogleMapURLをエンコード
                url = URI.encode ENV['G_STORE_URL'] + "&query=#{hash[:results][n][:name]}&query_place_id=#{hash[:results][n][:place_id]}"
                data[n] = {photo: photo, name: hash[:results][n][:name], rating: hash[:results][n][:rating], 
                　review: hash[:results][n][:user_ratings_total], address: hash[:results][n][:formatted_address], url: url
                }
              end
              message = change_msg(message,data)
              client.reply_message(event['replyToken'], message)
              
            when 'テスト'
              data = change_msg(message)
              client.reply_message(event['replyToken'], data)
              
            else
              client.reply_message(event['replyToken'], {type: 'text', text: event.message['そのコマンドは存在しないよ！']})
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
              response = open(ENV['G_URL'] + "origin=#{user.start_lat},#{user.start_lng}&destination=#{user.arrival_lat},#{user.arrival_lng}&language=ja&key=" + ENV['G_KEY'])
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
    

    def change_msg(msg)
      case msg
      when "おはよう"
        response = open(ENV['W_URL'] + "?q=Aichi&APPID=" + ENV['W_KEY'])
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
      end
    end
    
    def change_msg(msg,data)
      case msg
      when "ラーメン","カフェ"
        result = {
          "type": "flex",
          "altText": "#{msg}に寄り道",
          "contents": {
            "type": "carousel",
            "contents": [
              {
                "type": "bubble",
                "size": "kilo",
                "hero": {
                  "type": "image",
                  "url": "#{data[0][:photo]}",
                  "size": "full",
                  "aspectMode": "cover",
                  "aspectRatio": "320:213"
                },
                "body": {
                  "type": "box",
                  "layout": "vertical",
                  "contents": [
                    {
                      "type": "text",
                      "text": "#{data[0][:name]}",
                      "weight": "bold",
                      "size": "sm",
                      "wrap": true
                    },
                    {
                      "type": "box",
                      "layout": "baseline",
                      "contents": [
                        {
                          "type": "icon",
                          "size": "xs",
                          "url": "https://scdn.line-apps.com/n/channel_devcenter/img/fx/review_gold_star_28.png"
                        },
                        {
                          "type": "text",
                          "text": "#{data[0][:rating]}",
                          "size": "xs",
                          "color": "#8c8c8c",
                          "margin": "md",
                          "flex": 0
                        },
                        {
                          "type": "text",
                          "text": "クチコミ #{data[0][:review]}件",
                          "flex": 0,
                          "margin": "md",
                          "size": "xs",
                          "color": "#8c8c8c"
                        }
                      ]
                    },
                    {
                      "type": "box",
                      "layout": "vertical",
                      "contents": [
                        {
                          "type": "box",
                          "layout": "baseline",
                          "spacing": "sm",
                          "contents": [
                            {
                              "type": "text",
                              "text": "#{data[0][:address]}",
                              "wrap": true,
                              "color": "#8c8c8c",
                              "size": "xs",
                              "flex": 5
                            }
                          ]
                        }
                      ]
                    }
                  ],
                  "spacing": "sm",
                  "paddingAll": "13px"
                },
                "footer": {
                  "type": "box",
                  "layout": "vertical",
                  "contents": [
                    {
                      "type": "button",
                      "action": {
                        "type": "uri",
                        "label": "ここにする！",
                        "uri": "#{data[0][:url]}"
                      }
                    }
                  ]
                }
              },
              {
                "type": "bubble",
                "size": "kilo",
                "hero": {
                  "type": "image",
                  "url": "#{data[1][:photo]}",
                  "size": "full",
                  "aspectMode": "cover",
                  "aspectRatio": "320:213"
                },
                "body": {
                  "type": "box",
                  "layout": "vertical",
                  "contents": [
                    {
                      "type": "text",
                      "text": "#{data[1][:name]}",
                      "weight": "bold",
                      "size": "sm",
                      "wrap": true
                    },
                    {
                      "type": "box",
                      "layout": "baseline",
                      "contents": [
                        {
                          "type": "icon",
                          "size": "xs",
                          "url": "https://scdn.line-apps.com/n/channel_devcenter/img/fx/review_gold_star_28.png"
                        },
                        {
                          "type": "text",
                          "text": "#{data[1][:rating]}",
                          "size": "xs",
                          "color": "#8c8c8c",
                          "margin": "md",
                          "flex": 0
                        },
                        {
                          "type": "text",
                          "text": "クチコミ #{data[1][:review]}件",
                          "color": "#8c8c8c",
                          "margin": "md",
                          "size": "xs",
                          "flex": 0
                        }
                      ]
                    },
                    {
                      "type": "box",
                      "layout": "vertical",
                      "contents": [
                        {
                          "type": "box",
                          "layout": "baseline",
                          "spacing": "sm",
                          "contents": [
                            {
                              "type": "text",
                              "text": "#{data[1][:address]}",
                              "wrap": true,
                              "color": "#8c8c8c",
                              "size": "xs",
                              "flex": 0
                            }
                          ]
                        }
                      ]
                    }
                  ],
                  "spacing": "sm",
                  "paddingAll": "13px"
                },
                "footer": {
                  "type": "box",
                  "layout": "vertical",
                  "contents": [
                    {
                      "type": "button",
                      "action": {
                        "type": "uri",
                        "label": "君に決めた！",
                        "uri": "#{data[1][:url]}"
                      }
                    }
                  ]
                }
              },
              {
                "type": "bubble",
                "size": "kilo",
                "hero": {
                  "type": "image",
                  "url": "#{data[2][:photo]}",
                  "size": "full",
                  "aspectMode": "cover",
                  "aspectRatio": "320:213"
                },
                "body": {
                  "type": "box",
                  "layout": "vertical",
                  "contents": [
                    {
                      "type": "text",
                      "text": "#{data[2][:name]}",
                      "weight": "bold",
                      "size": "sm",
                      "wrap": true
                    },
                    {
                      "type": "box",
                      "layout": "baseline",
                      "contents": [
                        {
                          "type": "icon",
                          "size": "xs",
                          "url": "https://scdn.line-apps.com/n/channel_devcenter/img/fx/review_gold_star_28.png"
                        },
                        {
                          "type": "text",
                          "text": "#{data[2][:rating]}",
                          "size": "xs",
                          "color": "#8c8c8c",
                          "margin": "md",
                          "flex": 0
                        },
                        {
                          "type": "text",
                          "text": "クチコミ #{data[2][:review]}件",
                          "margin": "md",
                          "size": "xs",
                          "color": "#8c8c8c",
                          "flex": 0
                        }
                      ]
                    },
                    {
                      "type": "box",
                      "layout": "vertical",
                      "contents": [
                        {
                          "type": "box",
                          "layout": "baseline",
                          "spacing": "sm",
                          "contents": [
                            {
                              "type": "text",
                              "text": "#{data[2][:address]}",
                              "wrap": true,
                              "color": "#8c8c8c",
                              "size": "xs",
                              "flex": 5
                            }
                          ]
                        }
                      ]
                    }
                  ],
                  "spacing": "sm",
                  "paddingAll": "13px"
                },
                "footer": {
                  "type": "box",
                  "layout": "vertical",
                  "contents": [
                    {
                      "type": "button",
                      "action": {
                        "type": "uri",
                        "label": "すき！",
                        "uri": "#{data[2][:url]}"
                      }
                    }
                  ]
                }
              },
              {
                "type": "bubble",
                "size": "kilo",
                "hero": {
                  "type": "image",
                  "url": "#{data[3][:photo]}",
                  "size": "full",
                  "aspectRatio": "320:213",
                  "aspectMode": "cover"
                },
                "body": {
                  "type": "box",
                  "layout": "vertical",
                  "contents": [
                    {
                      "type": "text",
                      "text": "#{data[3][:name]}",
                      "weight": "bold",
                      "size": "sm",
                      "wrap": true
                    },
                    {
                      "type": "box",
                      "layout": "baseline",
                      "contents": [
                        {
                          "type": "icon",
                          "url": "https://scdn.line-apps.com/n/channel_devcenter/img/fx/review_gold_star_28.png",
                          "size": "xs"
                        },
                        {
                          "type": "text",
                          "text": "#{data[3][:rating]}",
                          "margin": "md",
                          "size": "xs",
                          "color": "#8c8c8c",
                          "flex": 0
                        },
                        {
                          "type": "text",
                          "text": "クチコミ #{data[3][:review]}件",
                          "margin": "md",
                          "size": "xs",
                          "flex": 0,
                          "color": "#8c8c8c"
                        }
                      ]
                    },
                    {
                      "type": "box",
                      "layout": "vertical",
                      "contents": [
                        {
                          "type": "box",
                          "layout": "baseline",
                          "contents": [
                            {
                              "type": "text",
                              "text": "#{data[3][:address]}",
                              "color": "#8c8c8c",
                              "size": "xs",
                              "flex": 5,
                              "wrap": true
                            }
                          ],
                          "spacing": "sm"
                        }
                      ]
                    }
                  ],
                  "spacing": "sm"
                },
                "footer": {
                  "type": "box",
                  "layout": "vertical",
                  "contents": [
                    {
                      "type": "button",
                      "action": {
                        "type": "uri",
                        "label": "寄っちゃう！",
                        "uri": "#{data[3][:url]}"
                      }
                    }
                  ]
                }
              },
              {
                "type": "bubble",
                "size": "kilo",
                "hero": {
                  "type": "image",
                  "url": "#{data[4][:photo]}",
                  "aspectMode": "cover",
                  "size": "full",
                  "aspectRatio": "320:213"
                },
                "body": {
                  "type": "box",
                  "layout": "vertical",
                  "contents": [
                    {
                      "type": "text",
                      "text": "#{data[4][:name]}",
                      "weight": "bold",
                      "size": "sm",
                      "wrap": true
                    },
                    {
                      "type": "box",
                      "layout": "baseline",
                      "contents": [
                        {
                          "type": "icon",
                          "url": "https://scdn.line-apps.com/n/channel_devcenter/img/fx/review_gold_star_28.png",
                          "size": "xs"
                        },
                        {
                          "type": "text",
                          "text": "#{data[4][:rating]}",
                          "color": "#8c8c8c",
                          "margin": "md",
                          "size": "xs",
                          "flex": 0
                        },
                        {
                          "type": "text",
                          "text": "クチコミ #{data[4][:review]}件",
                          "color": "#8c8c8c",
                          "margin": "md",
                          "size": "xs",
                          "flex": 0
                        }
                      ]
                    },
                    {
                      "type": "box",
                      "layout": "vertical",
                      "contents": [
                        {
                          "type": "box",
                          "layout": "baseline",
                          "contents": [
                            {
                              "type": "text",
                              "text": "#{data[4][:address]}",
                              "color": "#8c8c8c",
                              "size": "xs",
                              "flex": 5,
                              "wrap": true
                            }
                          ],
                          "spacing": "sm"
                        }
                      ]
                    }
                  ],
                  "spacing": "sm"
                },
                "footer": {
                  "type": "box",
                  "layout": "vertical",
                  "contents": [
                    {
                      "type": "button",
                      "action": {
                        "type": "uri",
                        "label": "いくぅ！",
                        "uri": "#{data[4][:url]}"
                      }
                    }
                  ]
                }
              }
            ]
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

    def client
      @client ||= Line::Bot::Client.new { |config|
        config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
        config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
      }
    end
    
end