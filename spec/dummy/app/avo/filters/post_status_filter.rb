class PostStatusFilter < Avo::Filters::MultipleSelectFilter
  self.name = "Status"

  def apply(request, query, value)
    query.where(status: (value || []).map(&:to_i))
  end

  def options
    Post.statuses.invert
  end

  # def default
  #   [1]
  # end

  # def react
  #   # This filter will react to PublishedFilter if it's set and this on is not.
  #   if applied_filters.present? && applied_filters["PostStatusFilter"].blank?
  #     return [Post.statuses["published"]] if applied_filters["PublishedFilter"] == "published"
  #     return [Post.statuses["archived"]] if applied_filters["PublishedFilter"] == "unpublished"
  #   end
  # end
end
