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

  def react
    if applied_filters.present?
      return [Post.statuses["published"]] if applied_filters["PublishedFilter"] == "published"
      return [Post.statuses["archived"]] if applied_filters["PublishedFilter"] == "unpublished"
    end
  end
end
