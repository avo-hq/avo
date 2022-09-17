class NameFilter < Avo::Filters::TextFilter
  self.name = "Name filter"
  self.button_label = "Filter by name"

  def apply(request, query, value)
    query.where("name LIKE ?", "%#{value}%")
  end
end
