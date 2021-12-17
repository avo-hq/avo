# frozen_string_literal: true

class Avo::Fields::Common::MultipleFileViewerComponent < ViewComponent::Base
  include Avo::ApplicationHelper

  def initialize(id:, file:, is_image:, direct_upload: false, resource:, button_size: :md)
    @id = id
    @file = file
    @is_image = is_image
    @direct_upload = direct_upload
    @button_size = button_size
    @resource = resource
  end
end
