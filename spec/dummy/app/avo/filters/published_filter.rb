class PublishedFilter < Avo::Filters::SelectFilter
  self.name = "Published status"

  def apply(request, query, value)
    case value
    when "published"
      query.where.not(published_at: nil)
    when "unpublished"
      query.where(published_at: nil)
    else
      query
    end
  end

  def options
    {
      blank: "Select status",
      published: "Published",
      unpublished: "Unpublished"
    }
  end

  # def default
  #   :published
  # end
end
