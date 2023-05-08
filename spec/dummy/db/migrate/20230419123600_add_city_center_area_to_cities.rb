class AddCityCenterAreaToCities < ActiveRecord::Migration[6.0]
  def change
    add_column :cities, :city_center_area, :json
  end
end
