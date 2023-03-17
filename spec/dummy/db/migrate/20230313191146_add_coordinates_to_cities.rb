class AddCoordinatesToCities < ActiveRecord::Migration[6.0]
  def change
    add_column :cities, :longitude, :float
    add_column :cities, :latitude, :float
  end
end
