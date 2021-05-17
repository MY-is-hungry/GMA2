class AddFirstSetupToCommutes < ActiveRecord::Migration[5.2]
  def change
    add_column :commutes, :first_setup, :boolean
  end
end
