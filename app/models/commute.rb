class Commute < ApplicationRecord
  belongs_to :user
  has_many :via_place, dependent: :destroy
  belongs_to :setup
  validates :user_id, presence: true, uniqueness: true

  def get_state
    if start_lat && end_lat && via_place.first
      0 #スタート、ゴール、中間地点あり
    elsif start_lat && end_lat
      1 #スタート、ゴールあり
    elsif start_lat
      2 #スタートあり
    elsif end_lat
      3 #ゴールあり
    else
      4 
    end
  end
  
  def get_setup_id
    if start_lat && end_lat && avoid && mode #全て設定済み
      1
    elsif start_lat && end_lat && avoid #残り通勤モード
      2
    elsif start_lat && end_lat && mode #残り経路制限
      3
    elsif start_lat && end_lat #残り経路制限、通勤モード
      4
    else #何も設定していない
      5
    end
  end
end
