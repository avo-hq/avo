class Person < ApplicationRecord
  has_many :spouses, foreign_key: :marriage_person_id
end
