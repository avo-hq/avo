class AddStoreToLocations < ActiveRecord::Migration[6.1]
  def change
    add_reference :locations, :store, foreign_key: true
  end
end
