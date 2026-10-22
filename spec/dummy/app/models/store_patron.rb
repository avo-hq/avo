class StorePatron < ApplicationRecord
  belongs_to :store
  belongs_to :user
  belongs_to :referrer, class_name: "User", optional: true

  validates :review, presence: true
end
