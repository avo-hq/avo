class Review < ApplicationRecord
  validates :body, presence: true

  belongs_to :reviewable, polymorphic: true, optional: true
  belongs_to :user, optional: true

  def tiny_name
    ActionView::Base.full_sanitizer.sanitize(body.to_s).truncate 60
  end
end
