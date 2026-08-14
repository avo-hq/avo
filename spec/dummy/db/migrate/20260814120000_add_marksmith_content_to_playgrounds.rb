class AddMarksmithContentToPlaygrounds < ActiveRecord::Migration[7.0]
  def change
    add_column :playgrounds, :marksmith_content, :text
  end
end
