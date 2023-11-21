class Avo::Filters::NameFilter < Avo::Filters::TextFilter
  self.name = "Name filter"
  self.button_label = "Filter by name"
  # self.visible = -> do
  #   Access to:
  #   block
  #   context
  #   current_user
  #   params
  #   parent_record
  #   parent_resource
  #   resource
  #   view_context
  # end

  def apply(request, query, value)
    if arguments[:case_insensitive]
      query.where("LOWER(name) LIKE ?", "%#{value.downcase}%")
    else
      query.where("name LIKE ?", "%#{value}%")
    end
  end
end
