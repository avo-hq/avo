class Spouse < Person
  belongs_to :person, foreign_key: :marriage_person_id
end
