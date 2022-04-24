# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  email                  :string           default(""), not null
#  first_name             :string
#  last_name              :string
#  roles                  :json
#  birthday               :date
#  custom_css             :text
#  team_id                :bigint
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  active                 :boolean          default(TRUE)
#  slug                   :string
#
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

  scope :active, -> { where active: true }
  scope :admins, -> { where "(roles->>'admin')::boolean is true" }
  scope :non_admins, -> { where "(roles->>'admin')::boolean != true" }

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

  def avo_title
    is_admin? ? "Admin" : "Member"
  end
end
