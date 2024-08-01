class StorePatron < ApplicationRecord
  belongs_to :store
  belongs_to :user

  validates :review, presence: true

  def review_two
    'hey'
  end
  def review_two=(value)
  end
end
