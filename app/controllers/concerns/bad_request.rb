module BadRequest
  extend ActiveSupport::Concern
  def bad_msg(msg)
    case msg
    when '中間地点登録'
      result = [
        {type: 'text',text: "出発地点か到着地点、もしくは両方とも設定されていません。"},
        {type: 'text',text: "「通勤設定」と送信して、設定してください。設定後、経路の中間地点を登録できます。",
        "quickReply": {
          "items": [
            {
              "type": "action",
              "action": {
                "type": "message",
                "label": "通勤設定",
                "text": "通勤設定"
              }
            }
          ]
        }}
      ]
    when '通勤時間'
      result = [
        {type: 'text',text: "出発地点か、到着地点が設定されていません。"},
        {type: 'text',text: "「通勤設定」と送信すると、設定できます。"}
      ]
      return result
    end
  end
end
