# frozen_string_literal: true

class InputComponentPreview < Lookbook::Preview
  include Avo::ApplicationHelper
  include ::ApplicationHelper

  def input
    render_with_template(template: "input_component_preview/input")
  end

  def date
    render_with_template(template: "input_component_preview/date")
  end

  def password
    render_with_template(template: "input_component_preview/password")
  end
end
