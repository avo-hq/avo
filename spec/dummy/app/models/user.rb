class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :posts
  has_and_belongs_to_many :projects
  has_and_belongs_to_many :teams

  has_one_attached :cv

  def is_admin?
    roles['admin'] === true
  end

  def name
    "#{first_name} #{last_name}"
  end
end
