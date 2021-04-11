module BaseRequest
  extend ActiveSupport::Concern
  include FavoriteRequest
  include SearchRequest
  include CommuteRequest
  
  def change_msg(msg, data='', count=0)
    case msg
    when 'おはよう'
      
    when '通勤設定','出発地点変更','到着地点変更','全設定','中間地点登録'
      commute_place(msg)
      
    when '中間地点削除'
      delete_via

    when '通勤時間'
      
    when 'ラーメン','ラーメン屋','らーめん','カフェ','喫茶店','コンビニ','ファミレス','焼肉','焼き肉','にく'
      search_store(msg, data)
      
    when 'お気に入り','おきにいり','おきに'
      fav_list(data,count)
      
    when '通勤モード'
      commute_mode(msg)
      
    when '経路制限'
      commute_limit(msg)
      
    when '寄り道地域'
      search_area_msg(msg, data)
      
    when 'コマンド一覧'
      [
        {
          "type": 'text',"text": 
          "通勤設定\n通勤経路を設定できます。流れに沿っていくと基本の設定が完了します。すでに設定済みの場合は、このコマンドを入力すると初期化されます。
          \n中間地点登録\n通勤経路の中間地点を登録できます。より正確なルートで通勤時間を計算できます。
          \n制限\n有料道路、高速道路、フェリーを使用するか選択できます。デフォルトでは、全て使用可能の状態になっています。
          \n通勤モード\n通勤時間を算出するゆとりを設定できます。
          \n通勤時間\n現在時刻の予想通勤時間を算出します。
          \n出発地点変更\n通勤設定で登録した、出発地点のみ変更します。
          \n到着地点変更\n通勤設定で登録した、到着地点のみ変更します。
          \n"
        },
        {
          "type": 'text',
          "text": "上記のコマンドは、画面左下のボタンから入力できます。"
        }
      ]
    end
  end
    
end