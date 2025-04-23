class CreateVolunteers < ActiveRecord::Migration[6.1]
  def change
    create_table :volunteers do |t|
      t.string :name
      t.string :role
      t.uuid :event_id, null: false

      t.timestamps
    end

    add_index :volunteers, :event_id
  end
end
