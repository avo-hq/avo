class Course::Link < ApplicationRecord
  belongs_to :course
  acts_as_list
  default_scope -> { order(position: :asc) }

  def self.table_name_prefix
    "course_"
  end
end
