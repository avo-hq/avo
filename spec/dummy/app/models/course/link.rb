class Course::Link < ApplicationRecord
  belongs_to :course

  def self.table_name_prefix
    'course_'
  end
end
