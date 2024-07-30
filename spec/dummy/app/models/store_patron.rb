class StorePatron < ApplicationRecord
  belongs_to :store
  belongs_to :user

  validates :review, presence: true
end
