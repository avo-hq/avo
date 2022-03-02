class User < ApplicationRecord
  extend FriendlyId
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :validatable

  validates :first_name, presence: true
  validates :last_name, presence: true

  has_one :post
  has_many :posts, inverse_of: :user
  has_many :people
  has_many :spouses
  has_many :comments
  has_and_belongs_to_many :projects
  has_and_belongs_to_many :teams, join_table: :team_memberships

  has_one_attached :cv

  friendly_id :name, use: :slugged

  def is_admin?
    roles.present? && roles["admin"].present?
  end

  def name
    "#{first_name} #{last_name}"
  end

  def notify(text)
    # notify about text
  end

  def avatar
    options = {
      default: "",
      size: 100
    }

    query = options.map { |key, value| "#{key}=#{value}" }.join("&")
    md5 = Digest::MD5.hexdigest(email.strip.downcase)

    URI::HTTPS.build(host: "www.gravatar.com", path: "/avatar/#{md5}", query: query).to_s
  end
end
