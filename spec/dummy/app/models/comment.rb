class Comment < ApplicationRecord
  validates :body, presence: true

  belongs_to :commentable, polymorphic: true, optional: true
  belongs_to :user, optional: true

  scope :starts_with, -> (prefix) { where('LOWER(body) LIKE ?', "#{prefix}%") }

  def tiny_name
    ActionView::Base.full_sanitizer.sanitize(body.to_s).truncate 30
  end
end
