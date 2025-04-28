class AddUuidToEvents < ActiveRecord::Migration[6.1]
  def change
    add_column :events, :uuid, :uuid
    add_index :events, :uuid, unique: true
  end
end
