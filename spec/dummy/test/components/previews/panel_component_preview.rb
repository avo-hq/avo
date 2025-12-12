class PanelComponentPreview < ViewComponent::Preview
  # Panel Component
  # ----------------------
  # A layout component for displaying entity details with optional sidebar
  #
  # @param sidebar_position select { choices: [relative, floating] } "relative"
  # @param show_sidebar toggle "true"
  def default(
    sidebar_position: :relative,
    show_sidebar: true
  )
    render_with_template(
      template: "panel_component_preview/default",
      locals: {
        sidebar_position: sidebar_position.to_sym,
        show_sidebar: show_sidebar
      }
    )
  end
end
