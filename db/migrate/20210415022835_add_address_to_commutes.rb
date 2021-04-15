class AddAddressToCommutes < ActiveRecord::Migration[5.2]
  def change
    add_column :commutes, :address, :string
  end
end