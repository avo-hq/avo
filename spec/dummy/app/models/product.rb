# == Schema Information
#
# Table name: products
#
#  id          :bigint           not null, primary key
#  title       :string
#  description :text
#  price       :integer
#  status      :string
#  category    :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class Product < ApplicationRecord
  enum category: [
    "Music players",
    "Phones",
    "Computers",
    "Wearables",
  ]

  has_one_attached :image
  has_many_attached :images
end
