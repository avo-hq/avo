class Avo::Fields::ColorPickerField < Avo::Fields::BaseField
  def initialize(id, **args, &block)
    super(id, **args, &block)

    @allow_non_colors = args[:allow_non_colors]
  end

  def view_component_namespace
    "Avo::Fields::ColorPickerField"
  end
end
