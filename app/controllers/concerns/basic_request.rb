module BasicRequest
  extend ActiveSupport::Concern
  def help_list
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