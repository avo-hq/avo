class CreateGalaxyPlanetSatellites < ActiveRecord::Migration[7.0]
  def change
    create_table :galaxy_planet_satellites do |t|
      t.string :name
      t.references :planet, null: false, foreign_key: {to_table: :galaxy_planets}

      t.timestamps
    end
  end
end
