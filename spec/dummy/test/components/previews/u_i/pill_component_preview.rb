module UI
  class PillComponentPreview < ViewComponent::Preview
    # @!group Interactive Playground

    # Interactive pill with customizable options
    # @param label text "Add filter"
    # @param icon text "tabler/outline/adjustments-horizontal"
    # @param selected toggle false
    # @param disabled toggle false
    # @param icon_only toggle false
    # @param counter text ""
    # @param filter_key text ""
    # @param filter_value text ""
    def playground(
      label: "Add filter",
      icon: "tabler/outline/adjustments-horizontal",
      selected: false,
      disabled: false,
      icon_only: false,
      counter: nil,
      filter_key: nil,
      filter_value: nil
    )
      render Avo::UI::PillComponent.new(
        label: label,
        icon: icon.present? ? icon : nil,
        selected: selected,
        disabled: disabled,
        icon_only: icon_only,
        counter: counter.present? ? counter : nil,
        filter_key: filter_key.present? ? filter_key : nil,
        filter_value: filter_value.present? ? filter_value : nil
      )
    end

    # @!endgroup

    # @!group Examples

    # All pill variants (default, selected, icon-only, disabled)
    def variants
      render_with_template(template: "u_i/pill_component_preview/variants")
    end

    # @!endgroup
  end
end
