class Galaxy::Planet::Satellite < ApplicationRecord
  belongs_to :planet,
    class_name: "Galaxy::Planet",
    inverse_of: :satellites,
    foreign_key: :planet_id
end
