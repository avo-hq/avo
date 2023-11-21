class Avo::Filters::IsAdmin < Avo::Filters::MultipleSelectFilter
  self.name = "Is admin"

  def apply(request, query, value)
    if value.include? 'admins'
      query = query.admins
    end

    if value.include? 'non_admins'
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

  # def default
  #   ['admins', 'non_admins']
  # end
end
