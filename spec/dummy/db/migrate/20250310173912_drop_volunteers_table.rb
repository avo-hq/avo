class DropVolunteersTable < ActiveRecord::Migration[8.0]
  def change
    drop_table :volunteers, if_exists: true
  end
end
