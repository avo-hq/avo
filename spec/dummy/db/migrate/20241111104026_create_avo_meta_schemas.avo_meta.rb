# This migration comes from avo_meta (originally 20241111092303)
class CreateAvoMetaSchemas < ActiveRecord::Migration[7.2]
  def change
    create_table :avo_meta_schemas do |t|
      t.string :resource_name
      t.json :schema_entries

      t.timestamps
    end

    add_index :avo_meta_schemas, :resource_name, unique: true
  end
end
