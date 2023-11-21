class Avo::Filters::FeaturedFilter < Avo::Filters::BooleanFilter
  self.name = "Featured status"

  def apply(request, query, values)
    return query if values['is_featured'] && values['is_unfeatured']

    if values['is_featured']
      query = query.where(is_featured: true)
    elsif values['is_unfeatured']
      query = query.where(is_featured: false)
    end

    query
  end

  def options
    {
      is_featured: "Featured",
      is_unfeatured: "Unfeatured"
    }
  end

  # def default
  #   {
  #     is_featured: true
  #   }
  # end
end
