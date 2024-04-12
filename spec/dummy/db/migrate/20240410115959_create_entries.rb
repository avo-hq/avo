class CreateEntries < ActiveRecord::Migration[6.1]
  def change
    create_table :entries do |t|
      t.integer :account_id
      t.integer :creator_id
      t.string :entryable_type
      t.integer :entryable_id

      t.timestamps
    end
  end
end
