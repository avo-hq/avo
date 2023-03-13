class AddLatitudeToCities < ActiveRecord::Migration[6.1]
  def change
    add_column :cities, :latitude, :float
  end
end
