# frozen_string_literal: true

class Avo::ResourceEditComponent < ViewComponent::Base
  include Avo::ResourcesHelper
  include Avo::ApplicationHelper

  def initialize(resource: nil)
    @resource = resource
  end
end
