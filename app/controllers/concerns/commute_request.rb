module CommuteRequest
  extend ActiveSupport::Concern
  def commute_place(msg, data: '')
    case data
    when 0, 1, 2, 3
      point, reset = ""
      case msg
      when '通勤設定'
        point = "出発"
        reset =
          case data
          when 0
            "出発地点、到着地点、中間地点"
          when 1
            "出発地点、到着地点"
          when 2
            "出発地点"
          when 3
            "到着地点"
          end
      when '出発地点変更'
        point, reset = "出発", "出発地点"
      when '到着地点変更'
        point, reset = "到着", "到着地点"
      end
      [
        {
          "type": "text", 
          "text": "#{reset}をリセットしました。"
        },
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
      ]
    else
      point =
        case msg
        when '出発地点変更','通勤設定'
          "出発地点"
        when '到着地点変更','通勤設定2'
          "到着地点"
        end
      {
        "type": "text",
        "text": "#{point}の位置情報を教えてください！",
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
    end
  end
  
  def via_create
    [
      {
        "type": "text",
        "text": "中間地点の位置情報を教えてください！"
      },
      {
        "type": "text",
        "text": "中間地点は登録順に通るよう通勤時間を計算します。",
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
    ]
  end
  
  def via_delete
    {type: 'text',text: "中間地点の設定をリセットしました。"}
  end
    
  def commute_mode(msg)
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
              "wrap": true
            },
            {
              "type": "text",
              "text": "※交通状況の変化もありますので、「ゆとり持つ」がオススメです。",
              "size": "sm",
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
  end
  
  def avoid_menu(msg)
    a = {}
    [
      a,
      {
        "type": "flex",
        "altText": "#{msg}設定",
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
                "weight": "bold",
                "wrap": true
              },
              {
                "type": "text",
                "text": "※複数ある場合は、それぞれ押してください。",
                "margin": "md",
                "color": "#8c8c8c",
                "wrap": true
              },
              {
                "type": "text",
                "text": "※初期設定では、全て含まれています。",
                "margin": "md",
                "color": "#8c8c8c",
                "wrap": true
              },
              {
                "type": "text",
                "text": "※誤った設定をした場合は、「経路の制限」と入力して選び直してください。",
                "color": "#8c8c8c",
                "wrap": true,
                "margin": "md"
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
                "layout": "vertical",
                "contents": [
                  {
                    "type": "button",
                    "action": {
                      "type": "postback",
                      "label": "全て使用する",
                      "data": "tolls|highways|ferries4"
                    },
                    "style": "secondary"
                  },
                  {
                    "type": "button",
                    "action": {
                      "type": "message",
                      "label": "やり直す",
                      "text": "経路の制限"
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
    ]
  end
  
  def change_avoid(commute)
    now = avoid_now(commute.avoid)
    if commute.via_place.first && commute.mode
      [
          {
            type: 'text',
            text: "設定を変更しました。"
          },
          {
            type: 'text',
            text: now
          }
      ]
    else
      unless commute.via_place.first
        [
          {
            type: 'text',
            text: "設定を変更しました。"
          },
          {
            type: 'text',
            text: now,
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
        ]
      else
        [
          {
            type: 'text',
            text: "設定を変更しました。"
          },
          {
            type: 'text',
            text: now,
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
        ]
      end
    end
  end
  
  def avoid_now(avoid)
    now =
      case avoid
      when "tolls|highways|ferries" then "全て"
      when "tolls|highways" then "フェリー"
      when "tolls|ferries" then "高速道路"
      when "highways|ferries" then "有料道路"
      when "tolls" then "高速道路、フェリー"
      when "highways" then"有料道路、フェリー"
      when "ferries" then "有料道路、高速道路"
      else "全て通勤ルートには使用しません。"
      end
    now = "現在は、#{now}が通勤経路に含まれる可能性があります。" unless now == "全て通勤ルートには使用しません。"
    return now
  end
end