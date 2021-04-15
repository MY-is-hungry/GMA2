class AddAddressToCommutes < ActiveRecord::Migration[5.2]
  def change
    add_column :commutes, :start_address, :string
    add_column :commutes, :end_address, :string
  end
end