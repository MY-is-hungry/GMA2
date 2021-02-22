module LinebotHelper
  def message_text(event)
    message = event.message['text']
    case message
    when 'おはよう'
      message = change_msg(message)
      result_msg = message.join
      client.reply_message(event['replyToken'],
        [{type: "text", text: result_msg}, {type: "text", text: 'テスト'}]);
        
    when '通勤設定'
      message = change_msg(message)
      client.reply_message(event['replyToken'], message);
      
    else
      message = hi
      client.reply_message(event['replyToken'], message);
    end
    
  end
  
  def message_location(event)
    
              
  end
end
