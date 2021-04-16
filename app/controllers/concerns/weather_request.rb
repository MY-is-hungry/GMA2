module WeatherRequest
  def weather_forcast(data)
    item = data[:list]
    forecastCityname = data[:city][:name]
    (0..5).each do |i|
      time = "#{item[i][:dt_txt].slice(-8, 2)}時"
      time.slice!(0) if time[0] == "0"
      forecasttemp = item[i][:main][:temp].round(1)
      weather_id = item[i][:weather][0][:id]
      weather = get_weather(weather_id)
      result[i] = "#{time}の天気は#{weather}\n温度は#{forecasttemp}℃\n"
    end
    result.unshift("今日の#{forecastCityname}の天気をお知らせします。\n")
    data.each do |d|
      logger.debug(d[-12,2])
    end
  end
  
  def get_weather(weather_id)
    case weather_id
    when 200, 201, 202, 210, 211, 212, 221, 230, 231, 232
      '雷雨'
    when 302, 312, 502, 503
      '激雨'
    when 300, 301, 310, 311, 313, 314, 500, 501, 504, 511, 522, 523
      'あめ'
    when 321, 520, 521, 531
      'に雨'
    when 600, 601, 602, 611, 612, 615, 616, 620, 621, 622
      'ゆき'
    when 701, 711, 721, 741
      'きり'
    when 731, 751, 761, 762, 781
      '異常'
    when 771
      'スコ'
    when 800
      '晴れ'
    when 801, 802, 803, 804
      '曇り'
    else
      '不明'
    end
  end
end