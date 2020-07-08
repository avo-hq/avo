class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :name, presence: true
  validates :description, presence: true
  validates :age, numericality: { greater_than: 0, less_than: 120 }

  has_many :posts
  has_and_belongs_to_many :projects

  has_one_attached :cv
  has_many_attached :docs
  has_one_attached :avatar
  has_many_attached :images
  has_and_belongs_to_many :teams

  def is_admin?
    roles['admin'] === true
  end
end
