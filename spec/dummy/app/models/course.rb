class Course < ApplicationRecord
  has_many :links, -> { order(position: :asc) }, class_name: 'Course::Link', inverse_of: :course
end
