class AddAvoidFirstToCommutes < ActiveRecord::Migration[5.2]
  def change
    add_column :commutes, :avoid_first, :boolean
  end
end
