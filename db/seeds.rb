User.create(id: "Testuser")
Setup.create(content: "基本設定は完了しました。お疲れ様でした！", next_setup: "通勤モード")
User.all.each do |user|
  Commute.create(user_id: user.id, setup_id: 1)
end