class AddBasicSetupStatusToCommutes < ActiveRecord::Migration[5.2]
  def change
    add_column :commutes, :basic_setup_status, :boolean
  end
end
