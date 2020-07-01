class AddSalaryToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :salary, :float8, default: 1550.25
  end
end
