class NameFilter < Avo::Filters::TextFilter
  self.name = "Name filter"
  self.button_label = "Filter by name"
  # self.visible = -> do
  #   Access to:
  #   block
  #   context
  #   current_user
  #   params
  #   parent_model
  #   parent_resource
  #   resource
  #   view_context
  # end

  def apply(request, query, value)
    query.where("name LIKE ?", "%#{value}%")
  end
end
