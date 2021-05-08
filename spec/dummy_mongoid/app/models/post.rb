class Post
  include Mongoid::Document

  # enum status: [:draft, :published, :archived]
  validates :name, presence: true

  # has_one_attached :cover_photo
  # has_many_attached :attachments

  # belongs_to :user, optional: true


  field :name, type: String
  field :body, type: String
  field :tags, type: String
  field :is_featured, type: Boolean
  field :status, type: Integer
end
