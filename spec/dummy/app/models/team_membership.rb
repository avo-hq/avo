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

  validate :fail, if: -> { ENV["MEMBERSHIP_FAIL"] == "true" }

  def fail
    errors.add(:team_membership, "dummy fail.")
  end

  def name
    "#{team&.name} - #{user&.name}"
  end
end
