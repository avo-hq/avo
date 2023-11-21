# == Schema Information
#
# Table name: cities
#
#  id               :bigint           not null, primary key
#  name             :string
#  population       :integer
#  is_capital       :boolean
#  features         :json
#  metadata         :json
#  image_url        :string
#  description      :text
#  status           :string
#  tiny_description :text
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  latitude         :float
#  longitude        :float
#  city_center_area :json
#
class City < ApplicationRecord
  enum status: {Open: "open", Closed: "closed", Quarantine: "On Quarantine"}
  has_rich_text :description
  has_one_attached :description_file

  def random_image=(value)
  end

  def random_image
    "https://source.unsplash.com/random"
  end

  # Alternative to stored_as location field
  # def coordinates
  #   [latitude, longitude]
  # end

  # def coordinates=(value)
  #   self.latitude = value.first
  #   self.longitude = value.last
  # end

  # alternative to format_using and update_using
  # def json_metadata
  #   ActiveSupport::JSON.encode(metadata)
  # end

  # def json_metadata=(value)
  #   self.metadata = ActiveSupport::JSON.decode(value)
  # end

  def self.ransackable_attributes(auth_object = nil)
    ["created_at", "description", "features", "id", "image_url", "is_capital", "metadata", "name", "population", "status", "tiny_description", "updated_at"]
  end
end
