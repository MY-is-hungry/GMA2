module BadRequest
  extend ActiveSupport::Concern
  def bad_msg(msg)
    case msg
    when '中間地点登録','通勤時間','ラーメン','カフェ','コンビニ','ファミレス','焼肉',
      '寄り道地域','通勤モード','経路の制限'
      [
        {type: 'text',text: "出発地点と到着地点がない場合、この操作はできません。"},
        {type: 'text',text: "「通勤設定」から設定してください。",
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
      
    when 'お気に入り'
      {type: "text", text: "お気に入りが登録されていません。"}
      
    when 'avoid'
      [
        {"type": 'text',"text": "既に設定済みです。"},
        {"type": 'text',"text": "設定をやり直すには、下の「経路の制限」を押してください。",
        "quickReply": {
          "items": [
            {
              "type": "action",
              "action": {
                "type": "message",
                "label": "経路の制限",
                "text": "経路の制限"
              }
            }
          ]
        }}
      ]
    end
  end
end
