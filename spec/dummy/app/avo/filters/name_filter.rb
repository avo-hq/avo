class NameFilter < Avo::Filters::TextFilter
  self.name = "Name filter"

  def apply(request, query, value)
    query.where(name: value)
  end
end
