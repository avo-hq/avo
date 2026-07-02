module UI
  class CountComponentPreview < ViewComponent::Preview
    # Count
    # -----
    # A compact numeric pill that sits next to a label or title — used for the
    # active-filter count on the filters bar, unread-notification counts, etc.
    #
    # @param count number 3
    def default(count: 3)
      render_with_template(
        template: "u_i/count_component_preview/default",
        locals: { count: count }
      )
    end
  end
end
