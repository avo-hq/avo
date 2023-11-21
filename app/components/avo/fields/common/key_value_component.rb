# frozen_string_literal: true

class Avo::Fields::Common::KeyValueComponent < ViewComponent::Base
  include Avo::ApplicationHelper

  attr_reader :view

  def initialize(field:, form: nil, view: "show")
    @field = field
    @form = form
    @view = Avo::ViewInquirer.new(view)
  end
end
