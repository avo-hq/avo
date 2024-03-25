class ChangePriceInProducts < ActiveRecord::Migration[7.1]
  def change
    remove_column :products, :price

    change_table :products do |t|
      t.monetize :price
    end
  end
end
