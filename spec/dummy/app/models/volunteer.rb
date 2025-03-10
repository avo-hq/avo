class Volunteer < ApplicationRecord
  belongs_to :event, foreign_key: 'event_uuid', primary_key: 'uuid'

  validates :name, presence: true
  validates :role, presence: true
end
