module JsonRequest
  extend ActiveSupport::Concern
  include FavoriteRequest
  include SearchRequest
  def change_msg(msg, data='', count=0)
    case msg
    when 'おはよう'
      response = open(ENV['W_URL'] + "?q=Aichi&APPID=" + ENV['W_KEY'])
      #JSONデータ(response)をハッシュ化
      data = JSON.parse(response.read, {symbolize_names: true})
      result = weather_text(data)
      return result
    when '通勤設定','出発地点変更'
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
    when '到着地点変更','全設定'
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
    when '中間地点登録'
      result = {
        "type": "text",
        "text": "中間地点の位置情報を教えてください！",
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
    when '中間地点削除'
      result = {type: 'text',text: "中間地点の設定を全て削除しました。"}
      return result
      
    when '通勤時間'
      
    when 'ラーメン','ラーメン屋','らーめん','カフェ','喫茶店','コンビニ','ファミレス','焼肉','焼き肉','にく'
      search_store(msg, data)
      
    when 'お気に入り','おきにいり','おきに'
      fav_list(data,count)
      
    when '通勤モード'
      result = {
        "type": "flex",
        "altText": "#{msg}の設定",
        "contents": {
          "type": "bubble",
          "header": {
            "type": "box",
            "layout": "vertical",
            "contents": [
              {
                "type": "text",
                "text": "通勤モードを選択してください。",
                "weight": "bold",
                "size": "xl",
                "wrap": true,
                "margin": "sm"
              },
              {
                "type": "text",
                "text": "※交通状況の変化もありますので、「ゆとり持つ」がオススメです。",
                "size": "xs",
                "wrap": true
              }
            ],
            "spacing": "sm"
          },
          "body": {
            "type": "box",
            "layout": "horizontal",
            "contents": [
              {
                "type": "button",
                "action": {
                  "type": "postback",
                  "data": "pessimistic1",
                  "label": "ゆとり持つ"
                },
                "style": "primary"
              },
              {
                "type": "button",
                "action": {
                  "type": "postback",
                  "label": "正確に",
                  "data": "best_guess1"
                },
                "style": "secondary"
              }
            ],
            "spacing": "md"
          }
        }
      }
      return result
    when '制限'
      result = {
        "type": "flex",
        "altText": "通勤経路の設定",
        "contents": {
          "type": "bubble",
          "size": "giga",
          "header": {
            "type": "box",
            "layout": "vertical",
            "contents": [
              {
                "type": "text",
                "text": "通勤経路に含まれるものを選んでください。",
                "size": "lg",
                "margin": "none",
                "weight": "bold",
                "wrap": true
              },
              {
                "type": "text",
                "text": "※複数回選択可能です。",
                "margin": "md",
                "color": "#8c8c8c"
              },
              {
                "type": "text",
                "text": "※誤った設定をした場合は、「制限」と入力して選び直してください。",
                "color": "#8c8c8c",
                "wrap": true,
                "margin": "sm"
              }
            ]
          },
          "body": {
            "type": "box",
            "layout": "vertical",
            "contents": [
              {
                "type": "box",
                "layout": "horizontal",
                "contents": [
                  {
                    "type": "button",
                    "action": {
                      "type": "postback",
                      "data": "hello",
                      "label": "高速道路"                        
                    },
                    "style": "primary"
                  },
                  {
                    "type": "button",
                    "action": {
                      "type": "postback",
                      "label": "有料道路",
                      "data": "tolls4"
                    },
                    "style": "primary"
                  },
                  {
                    "type": "button",
                    "action": {
                      "type": "postback",
                      "label": "フェリー",
                      "data": "hello"
                    },
                    "style": "primary"
                  },
                ],
                "spacing": "md"
              },
              {
                "type": "box",
                "layout": "horizontal",
                "contents": [
                  {
                    "type": "button",
                    "action": {
                      "type": "postback",
                      "label": "全て使用しない",
                      "data": "tolls|highways|ferries4"
                    },
                    "style": "secondary"
                  }
                ],
                "spacing": "md",
                "margin": "md"
              }
            ]
          }
        }
      }
      return result
              
    when 'コマンド一覧'
      # result = 
        [{type: 'text',
        text: 
        "通勤設定\n通勤経路を設定できます。流れに沿っていくと基本の設定が完了します。すでに設定済みの場合は、このコマンドを入力すると初期化されます。
        \n中間地点登録\n通勤経路の中間地点を登録できます。より正確なルートで通勤時間を計算できます。
        \n制限\n有料道路、高速道路、フェリーを使用するか選択できます。設定していない場合、間違ったルートで通勤時間を算出する可能性があります。
        \n通勤モード\n通勤時間を算出するゆとりを設定できます。
        \n通勤時間\n現在時刻の予想通勤時間を算出します。
        \n出発地点変更\n通勤設定で登録した、出発地点のみ変更します。
        \n到着地点変更\n通勤設定で登録した、到着地点のみ変更します。
        \n"},
        {type: 'text',text: "上記のコマンドは、画面左下のボタンから入力できます。"}
      ]
      # return result
    end
  end
    
end