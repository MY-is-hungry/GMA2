class Setting < ApplicationRecord
  belongs_to :user
  has_many :commute
end
