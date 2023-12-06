class AddLocationToEvents < ActiveRecord::Migration[7.1]
  def change
    add_reference :events, :location, null: true, foreign_key: true
  end
end
