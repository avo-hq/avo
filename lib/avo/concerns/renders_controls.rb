module Avo::Concerns::RendersControls
  def render_control(control)
    send :"render_#{control.type}", control
  end

  private

  def actions_list_args(actions_list)
    {
      exclude: actions_list.exclude,
      include: actions_list.include,
      style: actions_list.style,
      color: actions_list.color,
      label: actions_list.label,
      size: actions_list.size,
      icon: actions_list.icon,
      icon_class: actions_list.icon_class,
      title: actions_list.title
    }
  end

  def render_link_to(link)
    tooltip = avo_tooltip_attributes(link.title)

    a_link link.path,
      **link.args.except(*Avo::Resources::Controls::BaseControl::CONTROL_OPTIONS),
      color: link.color,
      style: link.style,
      icon: link.icon,
      icon_class: link.icon_class,
      title: tooltip[:title], target: link.target,
      class: link.classes,
      size: link.size,
      data: {
        **link.data,
        **tooltip[:data]
      } do
      link.label
    end
  end

  def render_action(action)
    return if !can_see_the_actions_button?
    return if !action.action.visible_in_view(parent_resource: @parent_resource)

    tooltip = avo_tooltip_attributes(action.title)

    a_link Avo::Services::URIService.parse(action.path).append_query(via_related_name_query).to_s,
      color: action.color,
      style: action.style,
      icon: action.icon,
      icon_class: action.icon_class,
      title: tooltip[:title],
      size: action.size,
      # Tippy strips `title` when it builds the tooltip, so an icon-only link needs its own name.
      aria: action.label.blank? ? {label: action.title.presence || action.action.action_name} : {},
      data: {
        controller: "actions-picker",
        turbo_frame: Avo::MODAL_FRAME_ID,
        action_name: action.action.action_name,
        **tooltip[:data],
        action: "click->actions-picker#visitAction",
        turbo_prefetch: false,
        # When action has record present behave as standalone and keep always active.
        "actions-picker-target": (action.action.standalone || action.action.record.present?) ? "standaloneAction" : "resourceAction",
        disabled: action.action.disabled?,
        resource_name: resource_name_for(action.action.resource)
      } do
      action.label
    end
  end
end
