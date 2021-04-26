User.create(id: "Testuser")
User.all.each do |user|
  Commute.create(user_id: user.id)
end

Setting.create(content: "基本設定は完了しました。お疲れ様でした！")