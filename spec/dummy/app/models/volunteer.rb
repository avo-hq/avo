class Volunteer < ApplicationRecord
  belongs_to :event, primary_key: "uuid"
end
