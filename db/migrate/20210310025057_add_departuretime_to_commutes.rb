class AddArrivaltimeToCommutes < ActiveRecord::Migration[5.2]
  def change
    add_column :commutes, :arrival_time, :datetime
  end
end