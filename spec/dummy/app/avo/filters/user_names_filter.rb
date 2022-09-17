class UserNamesFilter < Avo::Filters::TextFilter
  self.name = "User names filter"
  self.button_label = "Filter by user names"
  self.empty_message = "Search by name"

  def apply(request, query, value)
    query.where("LOWER(first_name) like ?", "%#{value}%").or(query.where("LOWER(last_name) like ?", "%#{value}%"))
  end

  # def default
  #   'avo'
  # end
end
