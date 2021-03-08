class User < ApplicationRecord
  has_one :commute, dependent: :destroy
  validates :id, presence: true, uniqueness: true
end
