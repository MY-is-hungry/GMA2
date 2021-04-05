module BaseRequest
  extend ActiveSupport::Concern
  include FavoriteRequest
  include SearchRequest
  def change_msg(msg, data='', count=0)
    case msg
    when 'おはよう'
      response = open(ENV['W_URL'] + "?q=Aichi&APPID=" + ENV['W_KEY'])
      #JSONデータをハッシュ化
      data = JSON.parse(response.read, {symbolize_names: true})
      result = weather_text(data)
      return result
    when '通勤設定','出発地点変更','到着地点変更','全設定','中間地点登録'
      case msg
      when '出発地点変更','通勤設定'
        point = "出発"
      when '到着地点変更','全設定'
        point = "到着"
      when '中間地点登録'
        point = "中間"
      end
      {
        "type": "text",
        "text": "#{point}地点の位置情報を教えてください！",
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
    when '中間地点削除'
      {type: 'text',text: "中間地点の設定を全て削除しました。"}

    when '通勤時間'
      
    when 'ラーメン','ラーメン屋','らーめん','カフェ','喫茶店','コンビニ','ファミレス','焼肉','焼き肉','にく'
      search_store(msg, data)
      
    when 'お気に入り','おきにいり','おきに'
      fav_list(data,count)
      
    when '通勤モード'
      {
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
    when '制限'
      {
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
                "size": "xl",
                "margin": "none",
                "weight": "bold",
                "wrap": true
              },
              {
                "type": "text",
                "text": "※複数ある場合は、それぞれ押してください。",
                "margin": "md",
                "color": "#8c8c8c"
              },
              {
                "type": "text",
                "text": "※初期設定では、全て含まれています。",
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
                      "data": "tolls4",
                      "label": "有料道路"                        
                    },
                    "style": "primary"
                  },
                  {
                    "type": "button",
                    "action": {
                      "type": "postback",
                      "label": "高速道路",
                      "data": "highways4"
                    },
                    "style": "primary"
                  },
                  {
                    "type": "button",
                    "action": {
                      "type": "postback",
                      "label": "フェリー",
                      "data": "ferries4"
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
      
    when '寄り道地域'
      case data
      when 0
        {type: 'text',text: "準備中"}
      when 1
        {
          "type": "flex",
          "altText": "#{msg}の設定",
          "contents": {
            "type": "bubble",
            "body": {
              "type": "box",
              "layout": "vertical",
              "contents": [
                {
                  "type": "text",
                  "text": "寄り道する地域を選んでください。",
                  "size": "lg",
                  "wrap": true,
                  "weight": "bold"
                },
                {
                  "type": "text",
                  "text": "※自宅・職場とは、通勤設定で選んだ出発地点と到着地点です。",
                  "wrap": true,
                  "size": "xs",
                  "color": "#8c8c8c",
                  "margin": "sm"
                }
              ]
            },
            "footer": {
              "type": "box",
              "layout": "horizontal",
              "spacing": "sm",
              "contents": [
                {
                  "type": "button",
                  "style": "link",
                  "height": "sm",
                  "action": {
                    "type": "postback",
                    "data": "15",
                    "label": "自宅付近"
                  }
                },
                {
                  "type": "button",
                  "style": "link",
                  "height": "sm",
                  "action": {
                    "type": "postback",
                    "label": "職場付近",
                    "data": "25"
                  }
                }
              ],
              "flex": 0
            }
          }
        }
      end
    when 'コマンド一覧'
      [
        {
          "type": 'text',"text": 
          "通勤設定\n通勤経路を設定できます。流れに沿っていくと基本の設定が完了します。すでに設定済みの場合は、このコマンドを入力すると初期化されます。
          \n中間地点登録\n通勤経路の中間地点を登録できます。より正確なルートで通勤時間を計算できます。
          \n制限\n有料道路、高速道路、フェリーを使用するか選択できます。デフォルトでは、全て使用可能の状態になっています。
          \n通勤モード\n通勤時間を算出するゆとりを設定できます。
          \n通勤時間\n現在時刻の予想通勤時間を算出します。
          \n出発地点変更\n通勤設定で登録した、出発地点のみ変更します。
          \n到着地点変更\n通勤設定で登録した、到着地点のみ変更します。
          \n"
        },
        {
          "type": 'text',
          "text": "上記のコマンドは、画面左下のボタンから入力できます。"
        }
      ]
    end
  end
    
end