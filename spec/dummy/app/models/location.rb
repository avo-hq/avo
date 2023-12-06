# == Schema Information
#
# Table name: locations
#
#  id         :bigint           not null, primary key
#  store_id   :bigint           not null
#  team_id    :bigint           not null
#  name       :text
#  address    :string
#  size       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Location < ApplicationRecord
  belongs_to :store, optional: true
  belongs_to :team

  has_and_belongs_to_many :courses, inverse_of: :locations
end
