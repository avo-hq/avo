class CreateTypes < ActiveRecord::Migration[6.1]
  def change
    create_table :types do |t|
      t.string :title
      t.bigint :fish_id, null: false

      t.timestamps
    end
  end
end
