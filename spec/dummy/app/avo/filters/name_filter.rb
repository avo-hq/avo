class Avo::Filters::NameFilter < Avo::Filters::TextFilter
  # Notice that name is changing on each request
  self.name = -> { "Name filter #{rand(1000)}" }

  # Notice that label is NOT changing on each request
  self.button_label = "Filter by name #{rand(1000)}"
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
