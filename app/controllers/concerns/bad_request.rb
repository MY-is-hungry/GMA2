module BadRequest
  extend ActiveSupport::Concern
  def bad_msg(msg)
    case msg
    when '中間地点登録'
      [
        {type: 'text',text: "出発地点か到着地点、もしくは両方とも設定されていません。"},
        {type: 'text',text: "下の「通勤設定」から設定してください。設定後、経路の中間地点を登録できます。",
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
    when '中間地点削除'
      {type: 'text',text: "中間地点が設定されていません。"}
    when '通勤時間'
      [
        {type: 'text',text: "出発地点か、到着地点が設定されていません。"},
        {type: 'text',text: "「通勤設定」を押すと設定できます。",
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
    when 'お気に入り'
      {type: "text", text: "お気に入りが登録されていません。"}
    when 'ラーメン','カフェ','コンビニ','ファミレス','焼肉'
      {
        "type": "text",
        "text": "寄り道機能には、通勤場所の情報が必要です。",
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
        }
      }
    when 'avoid'
      [
        {type: 'text',text: "全て使用しないに設定済みです。"},
        {type: 'text',text: "設定をやり直すには、下の「制限」を押してください。",
        "quickReply": {
          "items": [
            {
              "type": "action",
              "action": {
                "type": "message",
                "label": "制限",
                "text": "制限"
              }
            }
          ]
        }}
      ]
    end
  end
end
