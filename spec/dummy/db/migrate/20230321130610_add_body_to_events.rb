class AddBodyToEvents < ActiveRecord::Migration[6.0]
  def change
    add_column :events, :body, :text
  end
end
