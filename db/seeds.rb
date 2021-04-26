User.create(id: "Testuser")
Setting.create(content: "基本設定は完了しました。お疲れ様でした！")
User.all.each do |user|
  Commute.create(user_id: user.id, setting_id: 1)
end