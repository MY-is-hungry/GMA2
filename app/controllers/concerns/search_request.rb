module SearchRequest
  extend ActiveSupport::Concern
  def search_store(msg, data)
    {
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
  end
end