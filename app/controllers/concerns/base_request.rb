module BaseRequest
  extend ActiveSupport::Concern
  include WeatherRequest
  include CommuteRequest
  include FavoriteRequest
  include SearchRequest
  include BasicRequest
  
  #msgの表記分け　日本語：メッセージアクションから　英語：ロケーション、ポストバックアクションから（ラーメンなどの検索は除く）
  def change_msg(msg, data: '', count: '', state: '', commute_time: '')
    case msg
    when '今日の天気'
      weather_forcast(data, @commute, commute_time)
      
    #ここからcommute_request.rb
    when '基本設定'
      commute_basic(msg, @commute)
      
    when '通勤設定','出発地点変更','到着地点変更','first_location'
      commute_place(msg, state)
      
    when 'end_location'
      entry_location(msg, @commute)
      
    when '中間地点登録'
      via_location
      
    when 'via_place'
      via_create(count, @commute)
      
    when '中間地点削除'
      via_delete

    when '通勤時間'
      commute_time_msg(data, state)
      
    when '通勤モード'
      mode_menu(msg)
      
    when 'mode'
      commute_mode(@commute)
      
    when '経路の制限'
      avoid_menu(msg, @commute)
      
    when 'changed', 'completed'
      set_avoid(msg, data, @commute)
      
    #favorite_request.rb
    when 'お気に入り'
      fav_list(data, count)
      
    #ここからsearch_request.rb
    when '寄り道エリア'
      search_area_msg(msg, data)
    
    when '寄り道する！'
      select_store_menu
    
    when 'ラーメン','カフェ','コンビニ','ファミレス','焼き肉'
      search_store(msg, data)
    
    #ここからbasic_request.rb
    when 'ヘルプ'
      help_list
      
    when 'リセット'
      reset_setting(state)
      
    when 'follow'
      follow_msg
    
    end
  end
    
end