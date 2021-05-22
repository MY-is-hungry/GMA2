module WeatherRequest
  extend ActiveSupport::Concern
  
  def weather_forcast(data, commute)
    city_name = []
    weather_data = []
    # t = 0
    data.each_with_index { |d, n| city_name[n] = d[:city][:name] }
    # while data[t]
    #   data[t][:list].each_with_index do |d, n|
    #     time = d[:dt_txt].slice(-8, 2).to_i + 9
    #     break if time > 24
    #     time -= 24 if time == 24
    #     temp = d[:main][:temp].round(1) #温度
    #     weather = get_weather(d[:weather][0][:id]) #天気idをもとにメソッドから天気を取得
    #     weather_data[t][n] = "\n\n#{time}時 天気:#{weather}   温度:#{temp}℃"
    #     logger.debug(weather_data)
    #   end
    #   weather_data[t].unshift("今日の#{city_name[t]}の天気をお知らせします。")
    #   t += 1
    # end
    data.each_with_index do |d, n|
      weather_data[n] = []
      d[:list].each do |l|
        time = l[:dt_txt].slice(-8, 2).to_i + 9
        break if time > 24
        time -= 24 if time == 24
        temp = l[:main][:temp].round(1) #温度
        weather = get_weather(l[:weather][0][:id]) #天気idをもとにメソッドから天気を取得
        weather_data[n].push("\n\n#{time}時 天気:#{weather}   温度:#{temp}℃")
        logger.debug(weather_data)
      end
      weather_data[n].unshift("今日の#{city_name[n]}の天気をお知らせします。")
      logger.debug(weather_data)
    end
    
    result =
      if weather_data.count == 2
        [{type: "text", text: weather_data[0].join}, {type: "text", text: weather_data[1].join}]
      else
        {type: "text", text: weather_data[0].join}
      end
    # if weather_data[1][0]
    #   result = [{type: "text", text: weather_data[0].join}, {type: "text", text: weather_data[1].join}]
    # else
    #   result = {type: "text", text: weather_data[0].join}
    # end
    result
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
end