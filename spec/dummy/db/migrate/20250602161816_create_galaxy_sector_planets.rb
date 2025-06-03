class CreateGalaxySectorPlanets < ActiveRecord::Migration[8.0]
  def change
    create_table :galaxy_sector_planets do |t|
      t.string :name

      t.timestamps
    end
  end
end
