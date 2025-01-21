class AddSizesToProducts < ActiveRecord::Migration[6.1]
  def change
    add_column :products, :sizes, :string, array: true, default: []
  end
end
