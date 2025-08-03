class AddRatingToProducts < ActiveRecord::Migration[8.0]
  def change
    add_column :products, :rating, :integer, default: 0, null: false
    add_index :products, :rating
    
    add_check_constraint :products, "rating >= 0 AND rating <= 5", name: "rating_range_check"
  end
end
