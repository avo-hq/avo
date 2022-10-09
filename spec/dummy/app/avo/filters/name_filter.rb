class NameFilter < Avo::Filters::TextFilter
  self.name = "Name filter"
  self.button_label = "Filter by name"
  # self.visible = ->(resource:, user:) do
  # end

  def apply(request, query, value)
    query.where("name LIKE ?", "%#{value}%")
  end
end
