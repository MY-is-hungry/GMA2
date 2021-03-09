class Commute < ApplicationRecord
  has_one :user, dependent: :destroy
  validates :user_id, presence: true, uniqueness: true
end
