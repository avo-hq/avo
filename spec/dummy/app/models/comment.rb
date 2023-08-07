# == Schema Information
#
# Table name: comments
#
#  id               :bigint           not null, primary key
#  commentable_type :string
#  commentable_id   :integer
#  body             :text
#  user_id          :bigint
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  posted_at        :datetime
#
class Comment < ApplicationRecord
  validates :body, presence: true
  validate :body_different

  has_one_attached :photo

  belongs_to :commentable, polymorphic: true, optional: true
  belongs_to :user, optional: true

  scope :starts_with, ->(prefix) { where("LOWER(body) LIKE ?", "#{prefix}%") }

  def self.ransackable_attributes(auth_object = nil)
    %w(id body)
  end

  def tiny_name
    ActionView::Base.full_sanitizer.sanitize(body.to_s).truncate 60
  end

  def body_different
    possible_comment = Comment.where(body: body).where.not(id: id).first
    if possible_comment.present?
      errors.add :body, message: "exists in another Comment."
    end
  end
end
