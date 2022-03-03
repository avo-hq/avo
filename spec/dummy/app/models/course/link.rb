class Course::Link < ApplicationRecord
  belongs_to :course
  acts_as_list
  default_scope -> { order(position: :asc, created_at: :desc) }

  def self.table_name_prefix
    'course_'
  end
end
