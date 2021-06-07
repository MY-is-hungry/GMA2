[weather]: https://openweathermap.org/
[direction]: https://developers.google.com/maps/documentation/directions/overview
[messaging]: https://developers.line.biz/ja/services/messaging-api/
# :sunny: GMA
毎日の通勤をサポートするアプリです。<br>
ワンタップでその日の天気、予想される通勤時間を教えてくれます。<br>
外食して帰りたい日には、寄り道機能で周辺のお店を探すことができます。<br>
<br>
<br>

## :dart: 作成した目的
通勤生活を送る中で、「忙しい朝に必要な情報をなるべく簡単に得たい！」と思い作成しました。<br>
<br>
<br>

## :video_game: 機能一覧
LINEのMessaging APIを使ったアプリなので、主要機能はリッチメニューを使うことで簡単に操作できるようにしています。
- **天気予報、通勤時間の取得**<br>
  このアプリのメイン機能です。<br>
  天気予報は、[Open Weather Map(オープンウェザーマップ)][weather]のAPI、<br>
  通勤時間は、Google Maps Platformの[Directions API][direction]から取得しています。<br>
  <br>
- **寄り道機能**<br>
  寄り道するお店のジャンルを選択することで、お店の候補を出してくれます。<br>
  GoogleMapに移動することで、ルート案内もしてくれます。<br>
  <br>
- **お気に入り機能**<br>
  寄り道機能で表示されたお店の中から、気に入ったお店を登録できます。<br>
  お気に入り一覧からGoogleMapに移動することで、お店へのルート案内も可能です。<br>
  <br>
- **各種設定**<br>
  リッチメニュー、クイックリプライ、ボタンメッセージなどを使うことで、より直感的に設定ができるようにしています。<br>
  <br>
