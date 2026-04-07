class Avo::Filters::ProjectCountryFilter < Avo::Filters::BooleanFilter
  self.name = "Country"

  def apply(request, query, values)
    query.where(country: values.select { |_k, v| v }.keys)
  end

  def options
    Project.unscoped.distinct.pluck(:country).compact.sort.map { |c| [c, c] }.to_h
  end
end
