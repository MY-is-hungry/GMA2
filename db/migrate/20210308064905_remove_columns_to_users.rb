class RemoveColumnsToUsers < ActiveRecord::Migration[5.2]
  def change
    change_table(:users) do |t|
      t.remove :start_lat
      t.remove :start_lng
      t.remove :arrival_lat
      t.remove :arrival_lng
    end
  end
end
