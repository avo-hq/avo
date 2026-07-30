class AddNotesToTeamMemberships < ActiveRecord::Migration[8.0]
  def change
    add_column :team_memberships, :notes, :string
  end
end
