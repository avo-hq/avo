# == Schema Information
#
# Table name: team_memberships
#
#  id         :bigint           not null, primary key
#  team_id    :bigint           not null
#  user_id    :bigint           not null
#  level      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class TeamMembership < ApplicationRecord
  belongs_to :team
  belongs_to :user

  validate :fail

  def fail
    # Comment return to test it
    return
    user.errors.add(:user, "dummy fail, shown when attaching a team from user page.")
    team.errors.add(:team, "dummy fail, shown when attaching a user from team page.")
    errors.add(:team_membership, "dummy fail, never shown since join record is never used.")
  end

  def name
    "#{team&.name} - #{user&.name}"
  end
end
