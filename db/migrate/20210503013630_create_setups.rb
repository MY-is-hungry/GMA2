class CreateSetups < ActiveRecord::Migration[5.2]
  def change
    create_table :setups do |t|
      t.string :content
      t.string :next_setup

      t.timestamps
    end
    add_reference :commutes, :setup, foreign_key: true
  end
end
