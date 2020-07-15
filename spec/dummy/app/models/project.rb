class Project < ApplicationRecord
  validates :name, presence: true
  validates :users_required, numericality: { greater_than: 9, less_than: 1000000 }

  has_many_attached :files

  has_and_belongs_to_many :users
end
