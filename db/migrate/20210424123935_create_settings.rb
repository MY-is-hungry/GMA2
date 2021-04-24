class CreateSettings < ActiveRecord::Migration[5.2]
  def change
    create_table :settings do |t|
      t.text :content
      
      t.timestamps
    end
    
    add_column :commutes, :setting_id, :integer
    add_foreign_key :commutes, :settings, column: :setting_id
  end
end
