class Commute < ApplicationRecord
  belongs_to :user
  has_many :via_place, dependent: :destroy
  belongs_to :setup
  validates :user_id, presence: true, uniqueness: true

  #位置情報の設定状況を返す
  def get_state
    if start_lat && end_lat && via_place.first #スタート、ゴール、中間地点あり
      0
    elsif start_lat && end_lat #スタート、ゴールあり
      1
    elsif start_lat #スタートあり
      2
    elsif end_lat #ゴールあり
      3
    else #設定なし
      4 
    end
  end
  
  #基本設定の設定状況を返す
  def get_setup_id
    if start_lat && end_lat && avoid && mode #全て設定済み
      1
    elsif start_lat && end_lat && avoid #残り通勤モード
      2
    elsif start_lat && end_lat && mode #残り経路制限
      3
    elsif start_lat && end_lat #残り通勤モード、経路制限
      4
    else #設定なし
      5
    end
  end
end
