class AddShoesizeToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :shoesize, :string
  end
end
