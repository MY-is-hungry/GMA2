class User < ApplicationRecord
  has_one :commute, dependent: :destroy
  has_many :favorite, dependent: :destroy
  validates :id, presence: true, uniqueness: true
end
