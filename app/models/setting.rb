class Setting < ApplicationRecord
  has_many :user
  has_many :commute
end
