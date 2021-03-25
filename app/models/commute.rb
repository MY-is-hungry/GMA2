class Commute < ApplicationRecord
  belongs_to :user, dependent: :destroy
  has_many :via_place, dependent: :destroy
  validates :user_id, presence: true, uniqueness: true

  def get_state
    if start_lat && arrival_lat && via_place.first
      state = 0 #スタート、ゴール、中間地点あり
    elsif start_lat && arrival_lat
      state = 1 #スタート、ゴールあり
    elsif start_lat
      state = 2 #スタートあり
    elsif arrival_lat
      state = 3 #ゴールあり
    else
      state = 4 #通勤設定
    end
    return state
  end
end
