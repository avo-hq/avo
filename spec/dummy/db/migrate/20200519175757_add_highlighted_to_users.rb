class AddHighlightedToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :highlighted, :string, default: 'no'
  end
end

