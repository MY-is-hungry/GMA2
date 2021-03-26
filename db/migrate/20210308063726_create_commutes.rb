class CreateCommutes < ActiveRecord::Migration[5.2]
  def change
    create_table :commutes do |t|
      t.references :user, type: :string, foreign_key: true, null: false
      t.float :start_lat
      t.float :start_lng
      t.float :end_lat
      t.float :end_lng
      t.string :mode

      t.timestamps
    end
  end
end