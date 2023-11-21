# frozen_string_literal: true

class Avo::ResourceSidebarComponent < ViewComponent::Base
  attr_reader :resource
  attr_reader :params
  attr_reader :view
  attr_reader :form
  attr_reader :fields
  attr_reader :index

  def initialize(resource: nil, sidebar: nil, index: nil, params: nil, form: nil, view: nil)
    @resource = resource
    @sidebar = sidebar
    @params = params
    @view = view
    @form = form
    @index = index
  end

  def render?
    Avo.license.has_with_trial(:resource_sidebar)
  end
end
