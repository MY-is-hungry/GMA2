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
通勤生活を送る中で、「朝は忙しいから情報を得るのに時間をかけたくない！」と思いこのアプリを作成しました。<br>
<br>
<br>

## :video_game: 機能一覧
LINEのMessaging APIを使ったアプリなので、主要機能はリッチメニューを使うことで簡単に操作できるようにしています。

- **天気予報、通勤時間の取得**<br>
  <br>
  ![今日の天気](https://user-images.githubusercontent.com/63504907/121140233-91094f00-c874-11eb-8726-1f0b0d287e36.jpg)<br>
  <br>
  このアプリのメイン機能です。<br>
  ワンタップで今日の天気予報（自宅付近と職場付近）と、予想される通勤時間が返ってきます。<br>
  あらかじめ基本設定をしておく必要があります。<br>
  <br>
  
- **寄り道機能**<br>
  <br>
  <img width=450 height=500 alt="寄り道機能" src="https://user-images.githubusercontent.com/63504907/121152268-03cbf780-c880-11eb-8470-70b9a04e2fe8.jpeg"><br>
  <br>
  寄り道するお店のジャンルを選択することで、お店の候補を出してくれます。（写真はラーメンを選択）<br>
  お店へのルート案内も可能です。<br>
  <br>
  
- **お気に入り機能**<br>
  寄り道機能で表示されたお店の中から、気に入ったお店をお気に入り登録できます。<br>
  お気に入り一覧から、お店へのルート案内が可能です。<br>
  <br>
  
- **各種設定**<br>
  LINEならではのリッチメニュー、クイックリプライ、ボタンメッセージなどの機能を使うことで、より直感的に設定ができるようにしています。<br>
  <br>
  <img width=550 height=350 alt="LINE機能説明" src="https://user-images.githubusercontent.com/63504907/121156253-81453700-c883-11eb-9247-4c10b532f649.jpg">
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

### デザイン
**・**[canva][canva]<br>
<br>
<img width=600 height=250 alt="デザイン作品" src="https://user-images.githubusercontent.com/63504907/121160305-efd7c400-c886-11eb-9d4f-fb973c5e767d.png">
<br>
<br>

## 最後に
最後まで読んでいただきありがとうございました。<br>
現在、**Docker**や**React.js**など新たな技術を学びながら**語学を勉強できる日記**を共同開発しています。<br>
未完成ではありますが、ぜひご覧ください。<br>
https://github.com/local3/diary
