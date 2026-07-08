class CreateGalaxyPlanets < ActiveRecord::Migration[7.0]
  def change
    create_table :galaxy_planets do |t|
      t.string :name

      t.timestamps
    end
  end
end
