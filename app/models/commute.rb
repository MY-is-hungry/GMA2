class Commute < ApplicationRecord
  belongs_to :user, dependent: :destroy
  validates :user_id, presence: true, uniqueness: true

  def get_state
    if start_lat && arrival_lat #なし
      state = 0
    elsif start_lat #最後のみ変更
      state = 1
    elsif arrival_lat
      state = 2 #スタートのみ変更
    else
      state = 3 #通勤設定、最初のくる時も同じ状況になってまう
    end
    return state
  end
end
