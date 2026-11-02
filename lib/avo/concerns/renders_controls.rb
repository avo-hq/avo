module Avo::Concerns::RendersControls
  def render_control(control)
    send :"render_#{control.type}", control
  end

  private

  def render_link_to(link)
    a_link link.path,
      **link.args.except(*Avo::Resources::Controls::BaseControl::CONTROL_OPTIONS),
      color: link.color,
      style: link.style,
      icon: link.icon,
      icon_class: link.icon_class,
      title: link.title, target: link.target,
      class: link.classes,
      size: link.size,
      data: {
        **link.data,
        tippy: link.title ? :tooltip : nil
      } do
      link.label
    end
  end
end
