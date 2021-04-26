User.create!(id: "Testuser")
Commute.create!(user_id: user.id)

#app/model/commute.rb get_setting_idの順番と対応しています。
Setting.create!(
  [
    {
      content: '基本設定は完了しました。お疲れ様でした！'
    },
    {
      content: ''
    },
    {
      content: ''
    },
    {
      content: ''
    },
    {
      content: ''
    },
    {
      content: ''
    },
    {
      content: ''
    },
    {
      content: ''
    },
    {
      content: ''
    },
    {
      content: ''
    },
    {
      content: ''
    },
    {
      content: ''
    }
  ]
)