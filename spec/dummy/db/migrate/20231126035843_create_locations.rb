class CreateLocations < ActiveRecord::Migration[6.1]
  def change
    create_table :locations do |t|
      t.references :team, null: false, foreign_key: true
      t.text :name
      t.string :address
      t.string :size

      t.timestamps
    end
  end
end
