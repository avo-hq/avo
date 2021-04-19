class Post < ApplicationRecord
  validates :name, presence: true

  has_one_attached :cover_photo
  has_many_attached :attachments

  belongs_to :user, optional: true
end
