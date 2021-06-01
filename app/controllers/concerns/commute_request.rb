module CommuteRequest
  extend ActiveSupport::Concern
  def commute_basic(msg, commute)
    set = Setup.find(commute.get_state)
    if set.id == 1
      {
        "type": 'text',
        "text": set.content
      }
    else
      {
        "type": 'text',
        "text": set.content,
        "quickReply": {
          "items": [
            {
              "type": "action",
              "action": {
                "type": "message",
                "label": set.label,
                "text": set.next_setup
              }
            }
          ]
        }
      }
    end
  end
  
  def commute_place(msg, state)
    case state
    when 1..8
      point, reset = ""
      case msg
      when '通勤設定'
        point = "出発"
        reset =
          case state
          when 1..4
            "出発地点、到着地点、中間地点"
          when 5..8
            "出発地点、到着地点"
          when 10
            "出発地点"
          when 9
            "到着地点"
          end
      when '出発地点変更'
        if state.in?([1,2,3,4])
          point, reset = "出発", "出発地点と中間地点"
        else
          point, reset = "出発", "出発地点"
        end
      when '到着地点変更'
        if state.in?([1,2,3,4])
          point, reset = "到着", "到着地点と中間地点"
        else
          point, reset = "到着", "到着地点"
        end
      end
      [
        {
          "type": "text", 
          "text": "#{reset}をリセットしました。"
        },
        {
          "type": "text", 
          "text": "通勤経路の#{point}地点を教えてください！",
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
        when '到着地点変更','first_location'
          "到着地点"
        end
      {
        "type": "text",
        "text": "通勤経路の#{point}を教えてください！",
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
  
  def entry_location(msg, commute)
    set = Setup.find(commute.setup_id)
    if commute.avoid && commute.mode
      {"type": 'text',"text": "到着地点を登録しました。"}
    else
      [
        {
          "type": 'text',
          "text": "到着地点を登録しました。"
        },
        {
          "type": 'text',
          "text": set.content,
          "quickReply": {
            "items": [
              {
                "type": "action",
                "action": {
                  "type": "message",
                  "label": set.label,
                  "text": set.next_setup
                }
              }
            ]
          }
        }
      ]
    end
  end
  
  def via_location
    [
      {
        "type": "text",
        "text": "出発地点と到着地点の中間地点を教えてください！"
      },
      {
        "type": "text",
        "text": "後でさらに追加する場合は、登録順に通るよう通勤時間を計算します。",
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
  
  def via_create(count, state)
    if state == 1
      {"type": 'text', "text": "#{count}つ目の中間地点を登録しました。"}
    else
      set = Setup.find(state)
      [
        {
          "type": 'text', 
          text: "#{count}つ目の中間地点を登録しました。"
        },
        {
          "type": 'text',
          "text": set.content,
          "quickReply": {
            "items": [
              {
                "type": "action",
                "action": {
                  "type": "message",
                  "label": set.label,
                  "text": set.next_setup
                }
              }
            ]
          }
        }
      ]
    end
  end
  
  def via_delete
    {"type": 'text',"text": "中間地点の設定をリセットしました。"}
  end
    
  def mode_menu(msg)
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
  
  def commute_time_msg(data, state)
    case state
    when 1
      {"type": 'text', "text": "現在時刻での通勤時間は、#{data}です。"}
    else
      set = Setup.find(state)
      [
        {
          "type": 'text',
          "text": "現在時刻での通勤時間は、#{data}です。"
        },
        {
          "type": 'text',
          "text": "基本設定を進めることで、通勤時間の精度が上がります。",
          "quickReply": {
            "items": [
              {
                "type": "action",
                "action": {
                  "type": "message",
                  "label": "基本設定をする",
                  "text": set.next_setup
                }
              }
            ]
          }
        }
      ]
    end
  end
  
  def commute_mode(commute)
    set = Setup.find(commute.setup_id)
    logger.debug(commute.setup_id)
    if commute.avoid
      {"type": 'text', "text": "通勤モードを設定しました。"}
    else
      [
        {
          "type": 'text',
          "text": "通勤モードを設定しました。"
        },
        {
          "type": 'text',
          "text": set.content,
          "quickReply": {
            "items": [
              {
                "type": "action",
                "action": {
                  "type": "message",
                  "label": set.label,
                  "text": set.next_setup
                }
              }
            ]
          }
        }
      ]
    end
  end
  
  def avoid_menu(msg, commute)
    result =
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
                "text": "通勤経路では使用しないものを選んでください。",
                "size": "xl",
                "weight": "bold",
                "wrap": true
              },
              {
                "type": "text",
                "text": "※選択が完了したら、「設定完了」を押してください。",
                "margin": "md",
                "color": "#8c8c8c",
                "wrap": true
              },
              {
                "type": "text",
                "text": "※「経路の制限」と送信すると設定をリセットできます。",
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
                    "style": "secondary"
                  },
                  {
                    "type": "button",
                    "action": {
                      "type": "postback",
                      "label": "高速道路",
                      "data": "highways4"
                    },
                    "style": "secondary"
                  },
                  {
                    "type": "button",
                    "action": {
                      "type": "postback",
                      "label": "フェリー",
                      "data": "ferries4"
                    },
                    "style": "secondary"
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
                      "data": "none4"
                    },
                    "style": "secondary"
                  },
                  {
                    "type": "button",
                    "action": {
                      "type": "postback",
                      "label": "全て使用しない",
                      "data": "tolls,highways,ferries4"
                    },
                    "style": "secondary"
                  },
                  {
                    "type": "button",
                    "action": {
                      "type": "postback",
                      "label": "設定完了",
                      "data": "完了4"
                    },
                    "style": "primary"
                  }
                ],
                "spacing": "md",
                "margin": "md"
              }
            ]
          }
        }
      }
    if commute.avoid
      [{"type": 'text', "text": "選択済みの設定をリセットしました。"}, result]
    else
      result
    end
  end
  
  def set_avoid(msg, data, commute)
    case msg
    when 'changed'
      name = get_data_name(data)
      {
        "type": 'text',
        "text": "#{name}"
      }
    when 'completed'
      now = avoid_now(commute.avoid)
      if commute.mode
        if commute.first_setup
          {
            "type": 'text',
            "text": "#{now}"
          }
        else
          commute.update(first_setup: true)
          set = Setup.find(commute.setup_id)
          [
            {
              "type": 'text',
              "text": "#{now}"
            },
            {
              "type": 'text',
              "text": "#{set.content}"
            }
          ]
        end
      else
        [
          {
            "type": 'text',
            "text": "#{now}",
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
      when "tolls|highways|ferries", "tolls|ferries|highways", "highways|tolls|ferries",
        "highways|ferries|tolls", "ferries|tolls|highways", "ferries|highways|tolls"
        "全て通勤ルートには含まない設定に変更しました。"
      when "tolls|highways", "highways|tolls" then "フェリー"
      when "tolls|ferries", "ferries|tolls" then "高速道路"
      when "highways|ferries", "ferries|highways" then "有料道路"
      when "tolls" then "高速道路、フェリー"
      when "highways" then "有料道路、フェリー"
      when "ferries" then "有料道路、高速道路"
      else "有料道路、高速道路、フェリー"
      end
    now = "最短ルートに#{now}が含まれる場合、使用する設定に変更しました。" unless now == "全て通勤ルートには含まない設定に変更しました。"
    now
  end
  
  def get_data_name(data)
    name =
      case data
      when "tolls,highways,ferries" then "有料道路、高速道路、フェリー"
      when "tolls" then "有料道路"
      when "highways" then "高速道路"
      when "ferries" then "フェリー"
      when "none" then "全て使用します。"
      end
    name = "#{name}を経路から除外しました。" unless data == "none"
    name
  end
end