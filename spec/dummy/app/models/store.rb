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

  has_many :patronships, class_name: :StorePatron
  has_many :patrons, through: :patronships, class_name: :User, source: :user
end
