class CreateVolunteers < ActiveRecord::Migration[8.0]
  def change
    create_table :volunteers do |t|
      t.string :name
      t.string :role
      t.uuid :event_uuid, null: false

      t.timestamps
    end
    add_index :volunteers, :event_uuid
  end
end
