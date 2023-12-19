# == Schema Information
#
# Table name: locations
#
#  id         :bigint           not null, primary key
#  team_id    :bigint           not null
#  name       :text
#  address    :string
#  size       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  store_id   :bigint
#
class Location < ApplicationRecord
  belongs_to :store, optional: true
  belongs_to :team, optional: true

  has_and_belongs_to_many :courses, inverse_of: :locations
end
