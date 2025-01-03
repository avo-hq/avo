class AddSizesToProducts < ActiveRecord::Migration[8.0]
  def change
    add_column :products, :sizes, :string, array: true, default: []
  end
end
