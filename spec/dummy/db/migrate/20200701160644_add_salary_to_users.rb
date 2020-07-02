class AddSalaryToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :salary, :string
  end
end
