class ButtonComponentPreview < Lookbook::Preview
  include Avo::ApplicationHelper
  include ::ApplicationHelper

  # @param label text "Text to display in the button"
  # @param size select { choices: [xs, sm, md, lg, xl] }
  # @param style select { choices: [primary, outline, tertiary, text, icon] }
  # @param color select { choices: [gray, red, green, blue] }
  # @param icon text "Icon to display in the button"
  def default(label: "Label", size: :md, style: :primary, color: :gray, icon: "tabler/outline/arrow-up")
    a_button(size:, style:, color:, icon:) do
      label
    end
  end

  def styles
    render_with_template(
      template: "button_component_preview/styles"
    )
  end

  def sizes
    render_with_template(
      template: "button_component_preview/sizes"
    )
  end

  def states
    render_with_template(
      template: "button_component_preview/states"
    )
  end

  def icon_only
    render_with_template(
      template: "button_component_preview/icon_only"
    )
  end
end
