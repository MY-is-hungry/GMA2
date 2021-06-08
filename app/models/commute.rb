class Commute < ApplicationRecord
  belongs_to :user, dependent: :destroy
  has_many :via_place, dependent: :destroy
  belongs_to :setup
  validates :user_id, presence: true, uniqueness: true
  validates :setup_id, presence: true

  def get_state
    if start_lat && end_lat && via_place.first && avoid && mode #全ての設定済み
      1
    elsif start_lat && end_lat && via_place.first && avoid
      2
    elsif start_lat && end_lat && via_place.first && mode
      3
    elsif start_lat && end_lat && via_place.first
      4
    elsif start_lat && end_lat && avoid && mode
      5
    elsif start_lat && end_lat && avoid
      6
    elsif start_lat && end_lat && mode
      7
    elsif start_lat && end_lat
      8
    elsif start_lat #スタートあり
      9
    elsif end_lat #ゴールあり
      10
    elsif avoid && mode
      11
    elsif avoid
      12
    elsif mode
      13
    else #設定なし
      14
    end
  end
end