class Entry < ApplicationRecord
  # belongs_to :account
  belongs_to :creator, class_name: "User"
  delegated_type :entryable, types: %w[Message Activity], dependent: :destroy
  delegate :title, to: :entryable
end
