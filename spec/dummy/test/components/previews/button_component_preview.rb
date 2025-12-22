class ButtonComponentPreview < Lookbook::Preview
  include Avo::ApplicationHelper
  include ::ApplicationHelper

  # @param label text "Text to display in the button"
  # @param size select { choices: [xs, sm, md, lg, xl] }
  # @param style select { choices: [primary, outline, text, icon] }
  # @param color select { choices: [gray, red, green, blue] }
  # @param icon text "Icon to display in the button"
  def default(label: "Click me", size: :md, style: :primary, color: :primary, icon: "heroicons/outline/paper-clip")
    render_with_template(
      template: "button_component_preview/default",
      locals: {
        label: label,
        size: size,
        style: style,
        color: color,
        icon: icon
      }
    )
  end
end
