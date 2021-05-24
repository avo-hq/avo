class Post < ApplicationRecord
  enum status: [:draft, :published, :archived]
  validates :name, presence: true

  has_one_attached :cover_photo
  has_many_attached :attachments

  belongs_to :user, optional: true
  has_many :comments, as: :commentable
end
