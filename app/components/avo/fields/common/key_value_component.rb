# frozen_string_literal: true

class Avo::Fields::Common::KeyValueComponent < ViewComponent::Base
  include Avo::ApplicationHelper

  def initialize(field:, form: nil, view: :show)
    @field = field
    @form = form
    @view = view
  end
end
