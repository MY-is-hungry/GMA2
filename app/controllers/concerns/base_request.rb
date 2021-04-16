module BaseRequest
  extend ActiveSupport::Concern
  include CommuteRequest
  include FavoriteRequest
  include SearchRequest
  include BasicRequest
  
  
  def change_msg(msg: '', data: '', count: 0)
    case msg
    when 'おはよう'
      data.each do |d|
        logger.debug(d)
        logger.debug(d[-12,2])
      end
    #ここからcommute_request.rb
    when '通勤設定','出発地点変更','到着地点変更','全設定','中間地点登録'
      commute_place(msg)
      
    when '中間地点削除'
      delete_via

    when '通勤時間'
      
      
    when '通勤モード'
      commute_mode(msg)
      
    when '経路制限'
      commute_limit(msg)
      
    #favorite_request.rb
    when 'お気に入り','おきにいり','おきに'
      fav_list(data,count)
      
    #ここからsearch_request.rb
    when '寄り道地域'
      search_area_msg(msg, data)
    
    when 'ラーメン','ラーメン屋','らーめん','カフェ','喫茶店','コンビニ','ファミレス','焼肉','焼き肉','にく'
      search_store(msg, data)
    
    #ここからbasic_request.rb
    when 'コマンド一覧'
      command_list
      
    when "follow"
      follow_message
      
    end
  end
    
end