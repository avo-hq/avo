class CreateStorePatrons < ActiveRecord::Migration[6.1]
  def change
    create_table :store_patrons do |t|
      t.integer :store_id
      t.integer :user_id
      t.string :review

      t.timestamps
    end
  end
end
