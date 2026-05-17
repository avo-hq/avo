class AddAvoPreferencesToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :avo_preferences, :jsonb, default: {}
  end
end
