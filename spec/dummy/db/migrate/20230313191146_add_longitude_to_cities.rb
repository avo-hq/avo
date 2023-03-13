class AddLongitudeToCities < ActiveRecord::Migration[6.1]
  def change
    add_column :cities, :longitude, :float
  end
end
