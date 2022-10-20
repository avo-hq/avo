# == Schema Information
#
# Table name: courses
#
#  id           :bigint           not null, primary key
#  name         :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  skills       :text             default([]), is an Array
#  country      :string
#  city         :string
#  starting_at  :date_time
#
class Course < ApplicationRecord
  has_many :links, -> { order(position: :asc) }, class_name: "Course::Link", inverse_of: :course

  validates :name, presence: true

  def has_skills
    true
  end

  def has_skills=(value)
    true
  end

  def skill_suggestions
    ["example suggestion", "example tag", name]
  end

  def skill_disallowed
    ["foo", "bar", id]
  end

  def self.countries
    ["USA", "Japan", "Spain", "Thailand"]
  end

  def self.cities
    {
      USA: ["New York", "Los Angeles", "San Francisco", "Boston", "Philadelphia"],
      Japan: ["Tokyo", "Osaka", "Kyoto", "Hiroshima", "Yokohama", "Nagoya", "Kobe"],
      Spain: ["Madrid", "Valencia", "Barcelona"],
      Thailand: ["Chiang Mai", "Bangkok", "Phuket"]
    }
  end
end
