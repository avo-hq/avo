class Review < ApplicationRecord
  validates :body, presence: true

  belongs_to :reviewable, polymorphic: true, optional: true
  belongs_to :user, optional: true
end
