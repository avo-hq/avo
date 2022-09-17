# == Schema Information
#
# Table name: fish
#
#  id         :bigint           not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Fish < ApplicationRecord
  belongs_to :user, optional: true
  has_many :reviews, as: :reviewable
  self.inheritance_column = nil

  def release
    # Dummy method
  end

  self.inheritance_column = nil

  def fish_type
    type
  end

  def fish_type=(value)
    self.type = value
  end

  def properties=(value)
    # properties should be an array
    puts ["properties in the Fish model->", value].inspect unless Rails.env.test?
  end

  def information=(value)
    # properties should be a hash
    puts ["information in the Fish model->", value].inspect unless Rails.env.test?
  end
end
