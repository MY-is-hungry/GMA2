User.create(id: "Testuser")
Setting.create(
  [
    {
      content: 
      {
        type: 'text', text: "基本設定は完了しました。お疲れ様でした！",
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
    },
    {
      content: ""
    }
  ]
)
User.all.each do |user|
  Commute.create(user_id: user.id, setting_id: 1)
end