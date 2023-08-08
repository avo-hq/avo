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

  has_one :admin_membership, -> { where level: :admin }, class_name: "TeamMembership", dependent: :destroy
  has_one :admin, through: :admin_membership, source: :user, inverse_of: :teams

  has_many :reviews, as: :reviewable

  def self.ransackable_attributes(auth_object = nil)
    %w(id name)
  end
end
