class AddUuidToEvents < ActiveRecord::Migration[8.0]
  def change
    add_column :events, :uuid, :uuid
    add_index :events, :uuid, unique: true
  end
end
