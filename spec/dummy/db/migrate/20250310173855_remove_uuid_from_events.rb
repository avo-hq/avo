class RemoveUuidFromEvents < ActiveRecord::Migration[8.0]
  def change
    remove_index :events, :uuid
    remove_column :events, :uuid
  end
end
