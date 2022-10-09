class NameFilter < Avo::Filters::TextFilter
  self.name = "Name filter"
  self.button_label = "Filter by name"
  # self.visible = ->(parent_model:, parent_resource:, resource:, user:) do
  # end

  def apply(request, query, value)
    query.where("name LIKE ?", "%#{value}%")
  end
end
