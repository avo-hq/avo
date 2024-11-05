class Avo::Fields::ComboboxField < Avo::Fields::BaseField
  attr_reader :query
  attr_reader :compute_label
  attr_reader :accept_free_text

  def initialize(id, **args, &block)
    super(id, **args, &block)

    # Store the original query
    @query = args[:query] || lambda {}
    add_string_prop args, :compute_label
    add_boolean_prop args, :accept_free_text, true
  end

  def label
    return value if compute_label.blank?

    compute_label.call(value)
  end
end
