class AddSizeToFishes < ActiveRecord::Migration[6.1]
  def change
    add_column :fish, :size, :string
  end
end
