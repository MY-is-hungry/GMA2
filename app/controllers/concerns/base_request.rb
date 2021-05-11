module BaseRequest
  extend ActiveSupport::Concern
  include WeatherRequest
  include CommuteRequest
  include FavoriteRequest
  include SearchRequest
  include BasicRequest
  
  def change_msg(msg, data: '', count: '', commute: '', state: '')
    case msg
    when 'おはよう'
      weather_forcast(data)
      
    #ここからcommute_request.rb
    when '基本設定'
      commute_basic(msg, commute: commute)
      
    when '通勤設定','出発地点変更','到着地点変更', '通勤設定2'
      commute_place(msg, state: state)
      
    when '中間地点登録'
      via_create
      
    when '中間地点削除'
      via_delete

    when '通勤時間'
      
      
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
    
    when 'ラーメン','ラーメン屋','らーめん','カフェ','喫茶店','コンビニ','ファミレス','焼肉','焼き肉','にく'
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