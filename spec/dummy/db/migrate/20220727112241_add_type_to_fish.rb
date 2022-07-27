class AddTypeToFish < ActiveRecord::Migration[6.0]
  def change
    add_column :fish, :type, :string
  end
end
