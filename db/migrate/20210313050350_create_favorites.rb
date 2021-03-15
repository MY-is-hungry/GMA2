class CreateFavorites < ActiveRecord::Migration[5.2]
  def change
    create_table :favorites do |t|
      t.references :user, type: :string, foreign_key: true, null: false
      t.string :place_id

      t.timestamps
    end
  end
end
