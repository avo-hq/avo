class Course < ApplicationRecord
  has_many :links, -> { order(position: :asc) }, class_name: 'Course::Link', inverse_of: :course

  def skill_suggestions
    ['example suggestion', 'example tag', self.name]
  end

  def skill_blacklist
    ['foo', 'bar', self.id]
  end
end
