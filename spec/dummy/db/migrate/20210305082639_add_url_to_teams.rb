class AddUrlToTeams < ActiveRecord::Migration[6.0]
  def change
    add_column :teams, :url, :string
  end
end
