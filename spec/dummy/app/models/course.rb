# == Schema Information
#
# Table name: courses
#
#  id         :bigint           not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  skills     :text             default([]), is an Array
#
class Course < ApplicationRecord
  has_many :links, -> { order(position: :asc) }, class_name: 'Course::Link', inverse_of: :course
end
