class Rack::Attack
  #同一のIPアドレスからのリクエストを1回/秒に制限
  Rack::Attack.throttle('req/ip', limit: 1, period: 1.second) do |req|
  req.ip
end
end