# == Schema Information
#
# Table name: projects
#
#  id             :bigint           not null, primary key
#  name           :string
#  status         :string
#  stage          :string
#  budget         :string
#  country        :string
#  users_required :integer
#  started_at     :datetime
#  meta           :json
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  description    :text
#  progress       :integer
#
class Project < ApplicationRecord
  enum stage: {
    Discovery: "discovery",
    Idea: "idea",
    Done: "done",
    "On hold": "on hold",
    Cancelled: "cancelled",
    Drafting: "drafting"
  }

  validates :name, presence: true
  validates :users_required, numericality: {greater_than: 9, less_than: 1000000}

  has_many_attached :files

  has_many :comments, as: :commentable
  has_many :reviews, as: :reviewable
  has_and_belongs_to_many :users, inverse_of: :projects

  default_scope { order(name: :asc) }

  def self.ransackable_attributes(auth_object = nil)
    ["budget", "country", "created_at", "description", "id", "meta", "name", "progress", "stage", "started_at", "status", "updated_at", "users_required"]
  end
end
