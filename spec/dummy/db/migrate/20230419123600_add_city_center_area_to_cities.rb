class AddCityCenterAreaToCities < ActiveRecord::Migration[6.1]
  def change
    add_column :cities, :city_center_area, :json
  end
end
