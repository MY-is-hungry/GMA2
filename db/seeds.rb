User.create(id: "Testuser")
User.all.each do |user|
  Commute.create(user_id: user.id)
end

#app/model/commute.rb get_setting_idの順番と対応しています。
Setting.create(content: '基本設定は完了しました。お疲れ様でした！')