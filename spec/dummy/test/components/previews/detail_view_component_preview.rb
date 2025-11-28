class DetailViewComponentPreview < ViewComponent::Preview
  # Detail View Component
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
      template: "detail_view_component_preview/default",
      locals: {
        sidebar_position: sidebar_position.to_sym,
        show_sidebar: show_sidebar
      }
    )
  end

  def with_floating_sidebar
    render_with_template(
      template: "detail_view_component_preview/default",
      locals: {
        sidebar_position: :floating,
        show_sidebar: true
      }
    )
  end

  def without_sidebar
    render_with_template(
      template: "detail_view_component_preview/default",
      locals: {
        sidebar_position: :relative,
        show_sidebar: false
      }
    )
  end

  def with_many_fields
    render_with_template(
      template: "detail_view_component_preview/with_many_fields",
      locals: {
        sidebar_position: :relative,
        show_sidebar: true
      }
    )
  end
end

