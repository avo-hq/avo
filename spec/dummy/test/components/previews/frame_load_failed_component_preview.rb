class FrameLoadFailedComponentPreview < ViewComponent::Preview
  # @param frame text "filter"
  # @param src text "/admin/resources/comments"
  def default(frame: "filter", src: "/admin/resources/comments")
    render_with_template(
      template: "frame_load_failed_component_preview/default",
      locals: {frame: frame, src: src}
    )
  end
end
