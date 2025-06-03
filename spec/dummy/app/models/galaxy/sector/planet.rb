class Galaxy::Sector::Planet < ApplicationRecord
  has_many :satellites, class_name: "Galaxy::Sector::Planet::Satellite", inverse_of: :planet, foreign_key: :galaxy_sector_planets_id
end
