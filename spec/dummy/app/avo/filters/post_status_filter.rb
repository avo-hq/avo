class PostStatusFilter < Avo::Filters::MultipleSelectFilter
  self.name = "Status"

  def apply(request, query, value)
    query.where(status: value.map(&:to_i))
  end

  def options
    Post.statuses.invert
  end
end
