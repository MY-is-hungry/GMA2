class AddSetStatusToCommutes < ActiveRecord::Migration[5.2]
  def change
    add_column :commutes, :set_status, :integer
  end
end
