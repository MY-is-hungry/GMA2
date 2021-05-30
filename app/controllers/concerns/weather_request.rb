module WeatherRequest
  extend ActiveSupport::Concern
  
  def weather_forcast(weather_data, commute)
    logger.debug(commute)
    city_name = []
    result = []
    today_weather = []
    weather_data.each_with_index do |w, n|
      city_name[n] = w[:city][:name]
      result[n] = []
      w[:list].each do |l|
        time = l[:dt_txt].slice(-8, 2).to_i + 9
        break if time > 24
        time -= 24 if time == 24
        temp = l[:main][:temp].round(1) #温度
        weather = get_weather(l[:weather][0][:id]) #天気idをもとにメソッドから天気を取得
        result[n].push("\n\n#{time}時 天気:#{weather}  温度:#{temp}℃")
        today_weather[n] = {"#{time}": weather}
      end
      result[n].unshift("今日の#{city_name[n]}の天気をお知らせします。")
    end
    message = get_weather_message(today_weather)
    if result.count == 2
      [{type: "text", text: result[0].join}, {type: "text", text: result[1].join}, {type: "text", text: message}]
    else
      [{type: "text", text: result[0].join}, {type: "text", text: message}]
    end
  end
  
  def get_weather(weather_id)
    case weather_id
    when 200, 201, 202, 210, 211, 212, 221, 230, 231, 232
      '雷雨'
    when 302, 312, 502, 503
      '激しい雨'
    when 300, 301, 310, 311, 313, 314, 500, 501, 504, 511, 522, 523
      '雨'
    when 321, 520, 521, 531
      'にわか雨'
    when 600, 601, 602, 611, 612, 615, 616, 620, 621, 622
      '雪'
    when 701, 711, 721, 741
      '霧'
    when 731, 751, 761, 762, 781
      '異常気象'
    when 771
      'スコール'
    when 800
      '晴れ'
    when 801, 802, 803, 804
      '曇り'
    else
      '不明'
    end
  end
  
  def get_weather_message(today_weather)
    if today_weather.count == 2
      if today_weather[0][:"6"] == '雪' || t[:"9"] == '雪' || today_weather[0][:"15"] == '雪' || today_weather[0][:"18"] == '雪' ||
        today_weather[1][:"6"] == '雪' || t[:"9"] == '雪' || today_weather[1][:"15"] == '雪' || today_weather[1][:"18"] == '雪'
        #通勤時間に雪が降る可能性がある
        return "今日は雪が降ります。\n道路が凍結している可能性があるので、時間に大きなゆとりを持ちましょう。"
      end
      if today_weather[0][:"6"].in?['雷雨', '激しい雨', '雨', 'にわか雨'] || today_weather[0][:"9"].in?['雷雨', '激しい雨', '雨', 'にわか雨'] ||
        today_weather[0][:"15"].in?['雷雨', '激しい雨', '雨', 'にわか雨'] || today_weather[0][:"18"].in?['雷雨', '激しい雨', '雨', 'にわか雨'] ||
        today_weather[1][:"6"].in?['雷雨', '激しい雨', '雨', 'にわか雨'] || today_weather[1][:"9"].in?['雷雨', '激しい雨', '雨', 'にわか雨'] ||
        today_weather[1][:"15"].in?['雷雨', '激しい雨', '雨', 'にわか雨'] || today_weather[1][:"18"].in?['雷雨', '激しい雨', '雨', 'にわか雨']
        #１日のどこかで雨が降る
        return "今日は雨が降ります。\n時間にゆとりを持ちましょう。"
      end
    else
    end
  end
end