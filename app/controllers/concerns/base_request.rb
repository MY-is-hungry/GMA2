module BaseRequest
  extend ActiveSupport::Concern
  include WeatherRequest
  include CommuteRequest
  include FavoriteRequest
  include SearchRequest
  include BasicRequest
  
  def change_msg(msg, data: '', count: '', commute: '', state: '')
    #msgの表記分け　日本語：メッセージアクションから　英語：ロケーション、ポストバックアクションから
    case msg
    when 'おはよう'
      weather_forcast(data)
      
    #ここからcommute_request.rb
    when '基本設定'
      commute_basic(msg, commute: commute)
      
    when '通勤設定','出発地点変更','到着地点変更', '通勤設定2'
      commute_place(msg, state: state)
      
    when 'end_location'
      entry_location(msg, commute)
      
    when '中間地点登録'
      via_location
      
    when 'via_place'
      via_create(count, state)
      
    when '中間地点削除'
      via_delete

    when '通勤時間'
      commute_time_msg(data, state)
      
    when '通勤モード'
      mode_menu(msg)
      
    when 'mode'
      commute_mode(commute: commute)
      
    when '経路の制限'
      avoid_menu(msg, commute)
      
    when '変更', '完了'
      change_avoid(msg, data, commute)
      
    #favorite_request.rb
    when 'お気に入り','おきにいり','おきに'
      fav_list(data, count)
      
    #ここからsearch_request.rb
    when '寄り道地域'
      search_area_msg(msg, data)
    
    when '寄り道する！'
      select_store_menu
    
    when 'ラーメン','カフェ','コンビニ','ファミレス','焼き肉',
      search_store(msg, data)
    
    #ここからbasic_request.rb
    when 'ヘルプ'
      help_list
      
    when 'リセット'
      logger.debug(state)
      reset_setting(state)
      
    when 'follow'
      follow_msg
    
    end
  end
    
end