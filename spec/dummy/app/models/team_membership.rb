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
  # Declared first so it wins over `raise_test_error`, letting specs exercise a
  # destroy that is *blocked* rather than one that blows up.
  before_destroy -> { throw :abort }, if: -> { ENV["MEMBERSHIP_ABORT_DESTROY"] == "true" }
  before_destroy :raise_test_error, if: -> { Rails.env.test? }

  validate :fail, if: -> { ENV["MEMBERSHIP_FAIL"] == "true" }

  def fail
    errors.add(:team_membership, "dummy fail.")
  end

  def name
    "#{team&.name} - #{user&.name}"
  end

  private

  def raise_test_error
    raise "Callback Called"
  end
end
