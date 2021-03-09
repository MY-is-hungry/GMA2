class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users, id: false, primary_key: :id do |t|
      t.string :id, null: false
      t.float :start_lat
      t.float :start_lng
      t.float :arrival_lat
      t.float :arrival_lng

      t.timestamps
    end
    add_index :users, :id, unique: true
  end
end
