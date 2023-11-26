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
  belongs_to :team
end
