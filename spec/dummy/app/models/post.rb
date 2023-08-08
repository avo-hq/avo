# == Schema Information
#
# Table name: posts
#
#  id           :bigint           not null, primary key
#  name         :string
#  body         :text
#  is_featured  :boolean
#  published_at :datetime
#  user_id      :bigint
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  status       :integer          default("draft")
#  slug         :string
#
class Post < ApplicationRecord
  enum status: [:draft, :published, :archived]

  validates :name, presence: true

  has_one_attached :cover_photo
  has_one_attached :audio
  has_many_attached :attachments

  belongs_to :user, optional: true
  has_many :comments, as: :commentable
  has_many :reviews, as: :reviewable

  acts_as_taggable_on :tags

  before_save :update_slug

  def self.tags_suggestions
    [
      {
        value: 1,
        label: "one",
        avatar: "https://images.unsplash.com/photo-1560363199-a1264d4ea5fc?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&w=256&h=256&fit=crop"
      },
      {
        value: 2,
        label: "two",
        avatar: "https://images.unsplash.com/photo-1567254790685-6b6d6abe4689?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&w=256&h=256&fit=crop"
      },
      {
        value: 3,
        label: "three",
        avatar: "https://images.unsplash.com/photo-1560765447-da05a55e72f8?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&w=256&h=256&fit=crop"
      }
    ]
  end

  def to_param
    slug || id
  end

  def self.find(input)
    input.to_i == 0 ? find_by_slug(input) : super
  end

  def update_slug
    self.slug = name.parameterize
  end

  def self.ransackable_attributes(auth_object = nil)
    %w(id name body)
  end
end
