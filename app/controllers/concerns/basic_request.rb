module BasicRequest
  extend ActiveSupport::Concern
  def help_list
    [
      {
        "type": 'text',"text":
        <<~HELP.chomp
          【ヘルプ】
          
          「基本設定」
          基本的な機能を使うために必要な設定です。
          
          「今日の天気」
          自宅周辺と、勤務地周辺の天気予報さらに、予想通勤時間も出ます。
          
          「ゴール変更」
          到着地点を変更します。
          
          「寄り道をする」
          登録したエリアでお店を検索します。
          
          「お気に入りの店」
          お気に入りに登録したお店の一覧を表示します。（最大５件まで）
        HELP
      },
      {
        "type": 'text',
        "text": "コマンドの詳細、上記以外のコマンドは、ノートをご確認ください。"
      }
    ]
  end
  
  def reset_setting(state)
    reset =
      case state
      when 1..4
        "基本設定と中間地点をリセットしました。"
      else
        "基本設定をリセットしました。"
      end
    {
        "type": 'text',
        "text": reset,
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