class AddBoolytestToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :bulian, :string
  end
end
