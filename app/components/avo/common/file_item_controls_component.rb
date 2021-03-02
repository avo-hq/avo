# frozen_string_literal: true

class Avo::Common::FileItemControlsComponent < ViewComponent::Base
  include Avo::ApplicationHelper

  def initialize(id:, file:, button_size:, resource:)
    @id = id
    @file = file
    @button_size = button_size
    @resource = resource
  end
end
