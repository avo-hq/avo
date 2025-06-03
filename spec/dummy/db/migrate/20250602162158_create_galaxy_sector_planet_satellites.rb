class CreateGalaxySectorPlanetSatellites < ActiveRecord::Migration[6.1]
  def change
    create_table :galaxy_sector_planet_satellites do |t|
      t.string :name
      t.references :galaxy_sector_planets, null: false, foreign_key: true, index: { name: "index_satellites_on_planets_id" }

      t.timestamps
    end
  end
end
