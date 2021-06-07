[weather]: https://openweathermap.org/
[direction]: https://developers.google.com/maps/documentation/directions/overview
[place]: https://developers.google.com/maps/documentation/places/web-service/overview
[messaging]: https://developers.line.biz/ja/services/messaging-api/
[canva]: https://www.canva.com/
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
  お店へのルート案内も可能です。<br>
  <br>
- **お気に入り機能**<br>
  寄り道機能で表示されたお店の中から、気に入ったお店をお気に入り登録できます。<br>
  こちらもお店へのルート案内が可能です。<br>
  <br>
- **各種設定**<br>
  リッチメニュー、クイックリプライ、ボタンメッセージなどを使うことで、より直感的に設定ができるようにしています。<br>
  <br>
  <br>

## :busts_in_silhouette: 友達追加QRコード
QRコード<br>
<br>
<br>

## :computer: 開発環境・使用技術
- Ruby 2.6.3
- Rails 5.2.6
- heroku 7.54.0
- AWS(Cloud9, EC2)

### 使用API
- [LINE Messaging API][messaging]
- [Open Weather Map(オープンウェザーマップ)][weather]
- Google Maps Platform
  -  [Directions API][direction]
  -  [Places API][place]
<br>

### デザイン
**・**[canva][canva]<br>
<br>
ロゴ（左） リッチメニュー（右）<br>
<img height=250 width=250 alt="GMAロゴ" src="https://user-images.githubusercontent.com/63504907/120992904-0239fb00-c7be-11eb-8751-b188fa44804d.png">
<img height=235 width=350 alt="リッチメニュー" src="https://user-images.githubusercontent.com/63504907/120993648-b63b8600-c7be-11eb-9f1d-4618575014b9.png">
<br>

## :wrench: データベース設計
ER図
<br>

## 最後に
最後まで読んでいただきありがとうございました。<br>
現在、**Docker**や**React**など新たな技術を勉強しながら**語学を勉強できる日記**を共同開発しています。<br>
未完成ではありますが、ぜひご覧ください。<br>
URL
