class Team < ApplicationRecord
  validates :name, presence: true

  has_many :memberships, class_name: "TeamMembership"
  has_many :team_members, through: :memberships, class_name: "User", source: :user

  has_one :admin_membership, -> { where level: :admin }, class_name: "TeamMembership", dependent: :destroy
  has_one :admin, through: :admin_membership, source: :user

  has_many :reviews, as: :reviewable
end
