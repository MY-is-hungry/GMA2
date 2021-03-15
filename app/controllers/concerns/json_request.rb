module JsonRequest
  extend ActiveSupport::Concern
  
  def change_msg(msg, data='')
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
    when 'ラーメン','ラーメン屋','らーめん','カフェ','喫茶店','コンビニ','ファミレス','焼肉','焼き肉','にく'
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
                      "type": "postback",
                      "label": "お気に入りに保存",
                      "data": "#{data[0][:place_id]}2"
                    }
                  },
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
                      "type": "postback",
                      "label": "お気に入りに保存",
                      "data": "#{data[1][:place_id]}2"
                    }
                  },
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
                      "type": "postback",
                      "label": "お気に入りに保存",
                      "data": "#{data[2][:place_id]}2"
                    }
                  },
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
                      "type": "postback",
                      "label": "お気に入りに保存",
                      "data": "#{data[3][:place_id]}2"
                    }
                  },
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
                      "type": "postback",
                      "label": "お気に入りに保存",
                      "data": "#{data[4][:place_id]}2"
                    }
                  },
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
    when 'お気に入り','おきにいり','おきに'
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
                "size": "lg",
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
    end
  end
    
end