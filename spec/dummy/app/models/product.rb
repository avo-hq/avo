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
  monetize :price_cents
  if Gem::Version.new(Rails.version) >= Gem::Version.new("7.3.0")
    enum :category, [
      "Music players",
      "Phones",
      "Computers",
      "Wearables"
    ]
  else
    enum category: [
      "Music players",
      "Phones",
      "Computers",
      "Wearables"
    ]
  end

  has_one_attached :image
  has_many_attached :images
end
