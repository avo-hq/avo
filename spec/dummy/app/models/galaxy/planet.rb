class Galaxy::Planet < ApplicationRecord
  has_many :satellites,
    class_name: "Galaxy::Planet::Satellite",
    inverse_of: :planet,
    foreign_key: :planet_id
end
