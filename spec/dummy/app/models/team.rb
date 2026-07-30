# == Schema Information
#
# Table name: teams
#
#  id          :bigint           not null, primary key
#  name        :string
#  description :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  url         :string
#  color       :string
#
class Team < ApplicationRecord
  validates :name, presence: true

  has_many :memberships, class_name: "TeamMembership"
  has_many :team_members, through: :memberships, class_name: "User", source: :user, inverse_of: :teams
  has_many :locations

  has_one :admin_membership, -> { where level: :admin }, class_name: "TeamMembership", dependent: :destroy
  has_one :admin, through: :admin_membership, source: :user, inverse_of: :teams

  # A *scoped* has_many :through — the collection counterpart of `admin`. The
  # scope is what tells one of a user's join rows from another, so detaching
  # here can't go through an unscoped lookup either.
  has_many :admin_memberships, -> { where level: :admin }, class_name: "TeamMembership"
  has_many :admins, through: :admin_memberships, source: :user

  has_many :reviews, as: :reviewable

  def self.ransackable_attributes(auth_object = nil)
    ["color", "created_at", "description", "id", "name", "updated_at", "url"]
  end
end
