class Post < ApplicationRecord
  belongs_to :user, optional: true
end
