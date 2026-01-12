class AddSettingPresentToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :setting_present, :boolean, default: false, null: false
  end
end
