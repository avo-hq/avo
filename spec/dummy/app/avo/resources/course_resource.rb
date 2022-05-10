class CourseResource < Avo::BaseResource
  self.title = :name
  self.includes = []
  self.search_query = ->(params:) do
    scope.ransack(id_eq: params[:q], name_cont: params[:q], m: "or").result(distinct: false)
  end
  self.keep_filters_panel_open = true

  field :id, as: :id
  field :name, as: :text
  field :country, as: :select, options: Course.countries.map { |country| [country, country] }.to_h
  field :city, as: :select, options: Course.cities.values.flatten.map { |city| [city, city] }.to_h
  field :links, as: :has_many, searchable: true, placeholder: "Click to choose a link"

  filter CourseCountryFilter
  filter CourseCityFilter
end
