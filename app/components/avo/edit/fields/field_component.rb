# frozen_string_literal: true

class Avo::Edit::Fields::FieldComponent < ViewComponent::Base
  include Avo::ResourcesHelper

  def initialize(field: nil, resource: nil, index: 0, form: nil, displayed_in_modal: false)
    @field = field
    @resource = resource
    @index = index
    @form = form
    @displayed_in_modal = displayed_in_modal
  end
end
