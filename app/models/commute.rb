class Commute < ApplicationRecord
  belongs_to :user, dependent: :destroy
  has_many :via_place, dependent: :destroy
  validates :user_id, presence: true, uniqueness: true

  def get_state
      logger.debug(via_place.first)
    if start_lat && arrival_lat && via_place.first #中間地点２つ目〜
      state = 5
    elsif start_lat && arrival_lat #中間地点設定
      state = 1
    elsif start_lat #最後のみ変更
      state = 2
    elsif arrival_lat
      state = 3 #スタートのみ変更
    else
      state = 4 #通勤設定
    end
    return state
  end
end
