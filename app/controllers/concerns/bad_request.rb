module BadRequest
  extend ActiveSupport::Concern
  def bad_message(n)
    case n
    when 1
      client.reply_message(event['replyToken'], [
        {type: 'text',text: "出発地点か到着地点、もしくは両方とも設定されていません。"},
        {type: 'text',text: "「通勤設定」と送信して、設定してください。設定後、経路の中間地点を登録できます。"}
      ])
    end
  end
end
