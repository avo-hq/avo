class CourseCountryFilter < Avo::Filters::BooleanFilter
  self.name = "Course country filter"

  def apply(request, query, values)
    query.where(country: values.select { |k, v| v }.keys)
  end

  def options
    Course.countries.map { |c| [c, c] }.to_h
  end
end
