# == Schema Information
#
# Table name: stores
#
#  id         :bigint           not null, primary key
#  name       :string
#  size       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Store < ApplicationRecord
  has_one :location
end
