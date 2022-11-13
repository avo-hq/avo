class AddVatTaxToProducts < ActiveRecord::Migration[6.1]
  def change
    add_column :products, :vat_tax, :integer, null: false, default: 0
  end
end
