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
  before_destroy :say_goodbye, if: -> { Rails.env.test? }

  def name
    "#{team&.name} - #{user&.name}"
  end

  private

  def say_goodbye
    raise "Callback Called"
  end
end
