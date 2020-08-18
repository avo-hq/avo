class AddActiveToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :active, :boolean, default: true
  end
end
