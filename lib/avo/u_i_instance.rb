# frozen_string_literal: true

class Avo::UIInstance
  def initialize(args, kwargs, &block)
    @args = args
    @kwargs = kwargs
    @block = block
  end

  MISSING_COMPONENT_CLASS = "Avo::ComponentMissingComponent"

  # Used in parent apps like this `ui.panel(...)`
  # @method: string "panel"
  # @return: (method: String) -> Component
  def method_missing(method, *args, **kwargs, &block)
    # ensure it has the "_component" suffix
    component_class = "#{method.to_s.delete_suffix("_component")}_component"
    full_class_name = full_class_name(component_class)
    ui_full_class_name = ui_full_class_name(component_class)

    if Object.const_defined?(full_class_name)
      full_class_name.safe_constantize.new(*args, **kwargs, &block)
    elsif Object.const_defined?(ui_full_class_name)
      ui_full_class_name.safe_constantize.new(*args, **kwargs, &block)
    else
      MISSING_COMPONENT_CLASS.safe_constantize.new(component_name: method)
    end
  end

  private

  def full_class_name(component_class) = "Avo::#{component_class.classify}"
  def ui_full_class_name(component_class) = "Avo::UI::#{component_class.classify}"
end
