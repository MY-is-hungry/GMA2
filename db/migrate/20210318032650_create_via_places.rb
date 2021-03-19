class CreateViaPlaces < ActiveRecord::Migration[5.2]
  def change
    create_table :via_places do |t|
      t.references :commute, foreign_key: true, null: false
      t.float :via_lat
      t.float :via_lng
      t.integer :order

      t.timestamps
    end
  end
end
