class CreateCities < ActiveRecord::Migration[6.0]
  def change
    create_table :cities do |t|
      t.string :name
      t.integer :population
      t.boolean :is_capital
      t.json :features
      t.json :metadata
      t.string :image_url
      t.text :description
      t.string :status
      t.text :tiny_description

      t.timestamps
    end
  end
end
