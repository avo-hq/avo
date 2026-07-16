class Avo::Filters::PostLongOptionsFilter < Avo::Filters::MultipleSelectFilter
  self.name = "Long options"

  # Only used to test that the options list scrolls when it overflows.
  def apply(request, query, value)
    query
  end

  def options
    (1..20).index_with { |index| "Option #{index}" }
  end
end
