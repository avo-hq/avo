class Course::Link::Visit < ApplicationRecord
  # belongs_to :link, class_name: "Course::Link"

  def self.table_name
    "course_link_visits"
  end
end
