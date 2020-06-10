class Team < ApplicationRecord
  has_many :memberships
  has_many :members, through: :memberships
end
