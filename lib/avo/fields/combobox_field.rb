class Avo::Fields::ComboboxField < Avo::Fields::BaseField
  attr_reader :query
  attr_reader :compute_label

  def initialize(id, **args, &block)
    super(id, **args, &block)

    # Store the original query
    @query = args[:query] || lambda {}
    add_string_prop args, :compute_label
  end

  def label
    return value if compute_label.blank?

    compute_label.call(value)
  end
end
