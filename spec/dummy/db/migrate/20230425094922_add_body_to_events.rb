class AddBodyToEvents < ActiveRecord::Migration[6.1]
  def change
    add_column :events, :body, :text
  end
end
