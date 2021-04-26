class PostStatusFilter < Avo::Filters::SelectFilter
  self.name = "Status"

  def apply(request, query, value)
    query.where(status: value)
  end

  def options
    Post.statuses.invert
  end
end
