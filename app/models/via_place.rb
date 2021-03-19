class ViaPlace < ApplicationRecord
  belongs_to :commute
  validates :commute_id, presence: true
  validates :via_lat, presence: true
  validates :via_lng, presence: true
  validates :order, presence: true
end
