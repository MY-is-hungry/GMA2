class User < ApplicationRecord
  has_many :commutes, dependent: :destroy
  validates :line_id, presence: true, uniqueness: true
end
