class Comment < ApplicationRecord
  validates :body, presence: true
  validate :body_different

  belongs_to :commentable, polymorphic: true, optional: true
  belongs_to :user, optional: true

  scope :starts_with, ->(prefix) { where("LOWER(body) LIKE ?", "#{prefix}%") }

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
