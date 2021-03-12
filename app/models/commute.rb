class Commute < ApplicationRecord
  belongs_to :user, dependent: :destroy
  validates :user_id, presence: true, uniqueness: true

  def get_state
    if start_lat && arrival_lat
      state = 1
    elsif start_lat
      state = 2
    elsif arrival_lat
      state = 3
    else
      state = 0
    end
    return state
  end
end
