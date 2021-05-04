class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users, id: :string, primarykey: :id do |t|

      t.timestamps
    end
    add_index :users, :id, unique: true
  end
end
