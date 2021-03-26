class AddColumnsToCommutes < ActiveRecord::Migration[5.2]
  def change
    add_column :commutes, :search_area, :integer
    add_column :commutes, :avoid, :string
  end
end
