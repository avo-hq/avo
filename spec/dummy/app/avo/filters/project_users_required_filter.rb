class Avo::Filters::ProjectUsersRequiredFilter < Avo::Filters::TextFilter
  self.name = "Users required"
  self.button_label = "Filter by users required"

  def apply(request, query, value)
    query.where(users_required: value.to_i)
  end
end
