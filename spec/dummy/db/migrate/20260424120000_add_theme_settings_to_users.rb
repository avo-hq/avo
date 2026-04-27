class AddThemeSettingsToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :theme_settings, :json, default: {}, null: false
  end
end
