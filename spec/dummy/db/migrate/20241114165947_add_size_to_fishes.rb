class AddSizeToFishes < ActiveRecord::Migration[8.0]
  def change
    add_column :fish, :size, :string
  end
end
