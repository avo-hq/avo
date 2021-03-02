# frozen_string_literal: true

class Avo::Common::FileItemControlsComponent < ViewComponent::Base
  include Avo::ApplicationHelper

  def initialize(id:, attachment:, button_size:, resource:)
    @id = id
    @attachment = attachment
    @button_size = button_size
    @resource = resource
  end
end
