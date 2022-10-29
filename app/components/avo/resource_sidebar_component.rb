# frozen_string_literal: true

class Avo::ResourceSidebarComponent < ViewComponent::Base
  attr_reader :resource
  attr_reader :params
  attr_reader :view
  attr_reader :form
  attr_reader :fields

  def initialize(resource: nil, fields: nil, index: nil, params: nil, form: nil, view: nil)
    @resource = resource
    @fields = fields
    @params = params
    @view = view
    @form = form
  end

  def render?
    Avo::App.license.has_with_trial(:resource_sidebar)
  end
end
