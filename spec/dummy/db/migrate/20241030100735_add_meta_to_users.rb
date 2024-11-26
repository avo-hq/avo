class AddMetaToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :meta, :json
  end
end
