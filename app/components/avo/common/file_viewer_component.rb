# frozen_string_literal: true

class Avo::Common::FileViewerComponent < ViewComponent::Base
  def initialize(id:, attachment:, is_image:, button_size: :md, resource:)
    @id = id
    @attachment = attachment
    @is_image = is_image
    @button_size = button_size
    @resource = resource
  end
end
