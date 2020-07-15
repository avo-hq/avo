class Post < ApplicationRecord
  validates :name, presence: true

  has_one_attached :cover_photo

  belongs_to :user, optional: true
end
