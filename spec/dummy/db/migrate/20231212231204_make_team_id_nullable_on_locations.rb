class MakeTeamIdNullableOnLocations < ActiveRecord::Migration[6.1]
  def change
    change_column :locations, :team_id, :bigint, null: true
  end
end
