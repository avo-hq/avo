class Galaxy::Sector::Planet::Satellite < ApplicationRecord
  belongs_to :planet, class_name: "Galaxy::Sector::Planet", inverse_of: :satellites, foreign_key: :galaxy_sector_planets_id
end
