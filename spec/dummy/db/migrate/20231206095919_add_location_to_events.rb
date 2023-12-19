class AddLocationToEvents < ActiveRecord::Migration[6.1]
  def change
    add_reference :events, :location, null: true, foreign_key: true
  end
end
