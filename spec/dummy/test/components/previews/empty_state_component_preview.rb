class EmptyStateComponentPreview < ViewComponent::Preview
  # @param message text "No record found"
  def default(message: "No record found")
    render_with_template(
      template: "empty_state_component_preview/default",
      locals: {message: message}
    )
  end
end
