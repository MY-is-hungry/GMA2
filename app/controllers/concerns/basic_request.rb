module BasicRequest
  extend ActiveSupport::Concern
  def help_list
    [
      {
        "type": 'text',"text":
        <<~TEXT
          基本設定　基本的な機能を使うために必要な設定です。
          
          ゴール変更　到着地点を変更します。
          
          中間地点登録　通勤経路の中間地点を登録できます。より正確なルートで通勤時間を計算できます。
          
          通勤モード　通勤時間を算出するゆとりを設定できます。
          
          通勤時間　現在時刻の予想通勤時間を算出します。
          
          出発地点変更　通勤設定で登録した、出発地点のみ変更します。
          
          到着地点変更　通勤設定で登録した、到着地点のみ変更します。
TEXT
      },
      {
        "type": 'text',
        "text": "上記のコマンドは、画面左下のボタンから入力できます。"
      }
    ]
  end
  
  def reset_setting(state)
    case state
    when 0
      {
        type: 'text',
        text: "基本設定と中間地点をリセットしました。",
        "quickReply": {
          "items": [
            {
              "type": "action",
              "action": {
                "type": "message",
                "label": "基本設定を始める",
                "text": "基本設定"
              }
            }
          ]
        }
      }
    else
      {
        type: 'text',
        text: "基本設定をリセットしました。",
        "quickReply": {
          "items": [
            {
              "type": "action",
              "action": {
                "type": "message",
                "label": "基本設定を始める",
                "text": "基本設定"
              }
            }
          ]
        }
      }
    end
  end
  
  def follow_msg
    {
      "type": "text",
      "text": "$よろしく$",
        "emojis": [
          {
            "index": 0,
            "productId": "5ac1bfd5040ab15980c9b435",
            "emojiId": "001"
          },
          {
            "index": 5,
            "productId": "5ac1bfd5040ab15980c9b435",
            "emojiId": "002"
          }
        ]
    }
  end
end