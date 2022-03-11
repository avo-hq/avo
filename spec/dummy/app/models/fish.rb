class Fish < ApplicationRecord
  has_many :reviews, as: :reviewable
end
