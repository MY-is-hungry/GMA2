class Commute < ApplicationRecord
  belongs_to :user, dependent: :destroy
  validates :user_id, presence: true, uniqueness: true
end
