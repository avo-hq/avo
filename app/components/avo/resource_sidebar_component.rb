# frozen_string_literal: true

class Avo::ResourceSidebarComponent < ViewComponent::Base
  attr_reader :resource
  attr_reader :fields
  attr_reader :params
  attr_reader :view
  attr_reader :form

  def initialize(resource: nil, fields: nil, index: nil, params: nil, form: nil, view: nil)
    @resource = resource
    @fields = fields
    @params = params
    @view = view
    @form = form
  end

  def render_field(field)
    render field.hydrate(
      resource: resource,
      model: resource.model,
      user: resource.user,
      view: view
    ).component_for_view(view).new(
      field: field,
      resource: resource,
      form: form,
      stacked: true
    )
  end
end
