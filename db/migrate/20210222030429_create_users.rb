class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users, id: :string, primarykey: :id do |t|
      t.float :start_lat
      t.float :start_lng
      t.float :arrival_lat
      t.float :arrival_lng

      t.timestamps
    end
    add_index :users, :id, unique: true
  end
end
