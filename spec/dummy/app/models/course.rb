class Course < ApplicationRecord
  has_many :link, class_name: 'Course::Link'
end
