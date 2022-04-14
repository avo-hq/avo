class IsAdmin < Avo::Filters::MultipleSelectFilter
  self.name = "Is admin"

  def apply(request, query, value)
    query
  end

  def options
    {
      admins: "Admins",
      non_admins: "Non admins",
    }
  end

  def default
    {
      admins: true,
      non_admins: true,
    }
  end
end
