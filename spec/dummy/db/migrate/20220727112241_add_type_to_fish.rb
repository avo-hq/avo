class AddTypeToFish < ActiveRecord::Migration[6.1]
  def change
    add_column :fish, :type, :string
  end
end
