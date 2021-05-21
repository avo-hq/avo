class Comment < ApplicationRecord
  belongs_to :commentable, polymorphic: true, optional: true
  belongs_to :user, optional: true

  def tiny_name
    ActionView::Base.full_sanitizer.sanitize(body).truncate 30
  end
end
