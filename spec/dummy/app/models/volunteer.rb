class Volunteer < ApplicationRecord
  belongs_to :event, primary_key: "uuid"

  # Define the department options with groups
  DEPARTMENT_OPTIONS = {
    "Administration" => [
      ["HR", "hr"],
      "Finance",
      ["Legal", "legal"]
    ],
    "Operations" => {
      "Events" => "events",
      "Logistics" => "logistics",
      "Facilities" => "facilities"
    },
    "Technology" => [
      ["Development", "development"],
      ["Support", "support"],
      ["Infrastructure", "infrastructure"]
    ]
  }.freeze

  # Define the skills options with groups
  SKILLS_OPTIONS = {
    "Technical Skills" => [
      ["Programming", "programming"],
      ["Database Management", "database"],
      ["System Administration", "sysadmin"]
    ],
    "Communication Skills" => [
      ["Public Speaking", "public_speaking"],
      ["Writing", "writing"],
      ["Translation", "translation"]
    ],
    "Leadership Skills" => [
      ["Team Management", "team_mgmt"],
      ["Project Management", "project_mgmt"],
      ["Strategic Planning", "strategic"]
    ]
  }.freeze
end
