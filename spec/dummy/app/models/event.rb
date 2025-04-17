# == Schema Information
#
# Table name: events
#
#  id          :bigint           not null, primary key
#  name        :string
#  event_time  :datetime
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  body        :text
#  location_id :bigint
#
class Event < ApplicationRecord
  has_rich_text :body

  belongs_to :location, optional: true
  has_many :volunteers, foreign_key: :event_uuid, primary_key: :uuid
  has_one_attached :profile_photo
  has_one_attached :cover_photo

  before_create -> { self.uuid = SecureRandom.uuid }

  def first_user
    User.first
  end

  def attendees
    raise "Test array resource, this method should not be called"
  end

  # This is testing that array block can access the record.something
  def attendees_from_block
    [
      {id: 1, name: "John Doe", role: "Software Developer", organization: "TechCorp"},
      {id: 2, name: "Jane Smith", role: "Data Scientist", organization: "DataPros"},
      {id: 3, name: "Emily Davis", role: "Product Manager", organization: "Startup Inc."},
      {id: 4, name: "Kevin Roberts", role: "CTO", organization: "FutureTech"},
      {id: 5, name: "Sarah Johnson", role: "UI/UX Designer", organization: "DesignWorks"},
      {id: 6, name: "Michael Lee", role: "Backend Engineer", organization: "CodeBase"},
      {id: 7, name: "Olivia Brown", role: "Project Coordinator", organization: "BuildIt"},
      {id: 8, name: "Ethan Williams", role: "AI Specialist", organization: "InnoBots"},
      {id: 9, name: "Sophia Martinez", role: "Marketing Strategist", organization: "Brandify"},
      {id: 10, name: "Jacob Wilson", role: "DevOps Engineer", organization: "OpsWorld"},
      {id: 11, name: "Ava Taylor", role: "Business Analyst", organization: "AnalyzeNow"},
      {id: 12, name: "William Hernandez", role: "Full Stack Developer", organization: "Webify"},
      {id: 13, name: "Mia Moore", role: "HR Manager", organization: "PeopleFirst"},
      {id: 14, name: "James Anderson", role: "Blockchain Developer", organization: "ChainWorks"},
      {id: 15, name: "Charlotte White", role: "Product Designer", organization: "Cre8tive"},
      {id: 16, name: "Benjamin Green", role: "Cybersecurity Analyst", organization: "SecureNet"},
      {id: 17, name: "Amelia Clark", role: "Data Engineer", organization: "BigData Solutions"},
      {id: 18, name: "Lucas Carter", role: "Scrum Master", organization: "AgileHub"},
      {id: 19, name: "Ella Thompson", role: "Software Architect", organization: "CodeVision"},
      {id: 20, name: "Alexander Scott", role: "Solutions Consultant", organization: "Innovate Consulting"}
    ]
  end
end
