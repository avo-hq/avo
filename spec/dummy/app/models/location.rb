# == Schema Information
#
# Table name: locations
#
#  id         :bigint           not null, primary key
#  city_id    :bigint           not null
#  team_id    :bigint           not null
#  name       :text
#  address    :string
#  size       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Location < ApplicationRecord
  belongs_to :city

  has_and_belongs_to_many :courses, inverse_of: :locations
end
