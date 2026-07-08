class Avo::Filters::ProjectUserFilter < Avo::Filters::SelectFilter
  self.name = "User"

  def apply(request, query, value)
    query.where(user_id: value)
  end

  def options
    User.all.map { |u| [u.id, u.name] }.to_h
  end
end
