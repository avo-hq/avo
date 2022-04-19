class IsAdmin < Avo::Filters::MultipleSelectFilter
  self.name = "Is admin"

  def apply(request, query, value)
    if value[:admins].present?
      query = query.admins
    end

    if value[:non_admins].present?
      query = query.non_admins
    end

    query
  end

  def options
    {
      admins: "Admins",
      non_admins: "Non admins",
    }
  end
end
