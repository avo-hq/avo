class AddUuidToEvents < ActiveRecord::Migration[8.0]
  def change
    add_column :events, :uuid, :uuid, default: "gen_random_uuid()", null: false
    add_index :events, :uuid, unique: true
  end
end
