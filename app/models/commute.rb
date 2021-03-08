class Commute < ApplicationRecord
  has_one :user
  validates :user_id, presence: true, uniqueness: true
end
