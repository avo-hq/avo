require 'reform'
# require 'reform-rails'

class Avo::ResourceForm < Reform::Form
  property :title
  property :description
  # validates :title, presence: true
end
