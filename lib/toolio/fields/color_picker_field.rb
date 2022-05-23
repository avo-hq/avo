class Toolio::Fields::ColorPickerField < Avo::Fields::BaseField
  def initialize(id, **args, &block)
    super(id, **args, &block)

    @allow_non_colors = args[:allow_non_colors]
  end

  def component_class(view = :index)
    "::Toolio::Fields::#{view_component_name}::#{view.to_s.camelize}Component"
  end
end
