class CreateGroupsTable < ActiveRecord::Migration[6.0]
  def change
    create_table :groups do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
