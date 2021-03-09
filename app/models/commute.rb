class Commute < ApplicationRecord
  has_one :user, depondent: :destroy
  validates :user_id, presence: true, uniqueness: true
end
