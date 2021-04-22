class ColorPickerField < Avo::Fields::BaseField
  def initialize(name, **args, &block)
    @defaults = {
      sortable: true,
      computable: true
    }.merge(@defaults || {})

    super(name, **args, &block)

    @allow_non_colors = args[:allow_non_colors]
  end
end
