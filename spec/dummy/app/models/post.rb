# == Schema Information
#
# Table name: posts
#
#  id           :bigint           not null, primary key
#  name         :string
#  body         :text
#  is_featured  :boolean
#  published_at :datetime
#  user_id      :bigint
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  status       :integer          default("draft")
#
class Post < ApplicationRecord
  enum status: [:draft, :published, :archived]
  validates :name, presence: true

  has_one_attached :cover_photo
  has_one_attached :audio
  has_many_attached :attachments

  belongs_to :user, optional: true
  has_many :comments, as: :commentable
  has_many :reviews, as: :reviewable
end
