class City < ApplicationRecord
  enum status: {Open: "open", Closed: "closed"}

  def random_image=(value)

  end

  def random_image
    'https://source.unsplash.com/random'
  end
end
