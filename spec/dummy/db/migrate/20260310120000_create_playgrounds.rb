class CreatePlaygrounds < ActiveRecord::Migration[6.1]
  def change
    create_table :playgrounds do |t|
      t.string :name
      t.string :text_value
      t.text :textarea_value
      t.text :code_value
      t.boolean :boolean_value, default: false, null: false
      t.integer :number_value
      t.date :date_value
      t.time :time_value
      t.datetime :date_time_value
      t.string :country_value
      t.string :hidden_token
      t.string :password_value
      t.string :select_value
      t.string :multi_select_values, array: true, default: []
      t.string :radio_value
      t.string :badge_value
      t.string :status_value
      t.integer :stars_value, default: 0, null: false
      t.integer :progress_value, default: 0, null: false
      t.string :tags_values, array: true, default: []
      t.json :boolean_group_values, default: {}
      t.json :key_value_data, default: {}
      t.string :external_image_url
      t.string :gravatar_email
      t.text :easy_mde_content
      t.text :tiptap_content
      t.float :latitude
      t.float :longitude
      t.json :area_coordinates
      t.string :array_values, array: true, default: []

      t.timestamps
    end
  end
end
