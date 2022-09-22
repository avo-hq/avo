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
