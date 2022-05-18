class DummyMultipleSelectFilter < Avo::Filters::MultipleSelectFilter
  self.name = "Dummy multiple select filter"

  def apply(request, query, value)
    query
  end

  def options
    {
      'yes': 'Yes',
      'no': 'No',
    }
  end

  def default
    ['yes']
  end
end
