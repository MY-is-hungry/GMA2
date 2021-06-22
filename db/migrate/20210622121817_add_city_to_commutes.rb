class AddCityToCommutes < ActiveRecord::Migration[5.2]
  def change
    add_column :commutes, :start_city, :string
    add_column :commutes, :end_city, :string
  end
end
