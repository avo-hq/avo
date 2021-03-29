class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :validatable

  validates :first_name, presence: true
  validates :last_name, presence: true

  has_one :post
  has_many :posts
  has_and_belongs_to_many :projects
  has_and_belongs_to_many :teams, join_table: :team_memberships

  has_one_attached :cv

  def is_admin?
    roles.present? && roles["admin"].present?
  end

  def name
    "#{first_name} #{last_name}"
  end

  def notify(text)
    # notify about text
  end
end
