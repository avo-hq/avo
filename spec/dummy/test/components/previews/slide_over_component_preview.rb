class SlideOverComponentPreview < ViewComponent::Preview
  def default
    render_with_template(
      template: "slide_over_component_preview/default"
    )
  end

  def with_long_body
    render_with_template(
      template: "slide_over_component_preview/with_long_body"
    )
  end

  def narrow_viewport
    render_with_template(
      template: "slide_over_component_preview/narrow_viewport"
    )
  end

  def with_backdrop_click_disabled
    render_with_template(
      template: "slide_over_component_preview/with_backdrop_click_disabled"
    )
  end
end
