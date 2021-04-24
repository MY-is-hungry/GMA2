class Commute < ApplicationRecord
  belongs_to :user, dependent: :destroy
  has_many :via_place, dependent: :destroy
  belongs_to :setting, dependent: :destroy
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
  
  def get_setting_id
    if start_lat && end_lat && avoid && via_place.first && mode #全て設定済み
      1
    elsif start_lat && end_lat && avoid && via_place.first #残り通勤モード
      2
    elsif start_lat && end_lat && avoid && mode #残り中間地点
      3
    elsif start_lat && end_lat && via_place.first && mode #残り経路制限
      4
    elsif start_lat && end_lat && avoid #残り中間地点、通勤モード
      5
    elsif start_lat && end_lat && via_place.first #残り経路制限、通勤モード
      6
    elsif start_lat && end_lat && mode #残り経路制限、中間地点
      7
    elsif start_lat && end_lat #残り経路制限、中間地点、通勤モード
      8
    else
      9
    end
  end
end
