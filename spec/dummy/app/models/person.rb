class Person < ApplicationRecord
  belongs_to :user, optional: true
  has_many :spouses, foreign_key: :person_id
end
