class AddNotesToTeamMemberships < ActiveRecord::Migration[7.0]
  def change
    add_column :team_memberships, :notes, :string
  end
end
