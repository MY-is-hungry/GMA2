class Setting < ApplicationRecord
  belongs_to :user
  belongs_to :commute
end
