class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string :line_id
      t.float :start_lat
      t.float :start_lng
      t.float :arrival_lat
      t.float :arrival_lng

      t.timestamps
    end
  end
end
