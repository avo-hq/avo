class People2Filter < Avo::Filters::BooleanFilter
  self.name = "People 2 status (temporary)"

  def apply(request, query, value = {})
    if value[:a_lot]
      query = query.where("users_required > ?", 30)
    end
    if value[:few]
      query = query.where("users_required <= ?", 30)
    end

    query
  end

  def options
    {
      'a_lot': "A lot",
      'few': "Few (< 30)"
    }
  end

  def default
    {few: true}
  end
end
