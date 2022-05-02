class CourseCityFilter < Avo::Filters::BooleanFilter
  self.name = "Course city filter"
  self.empty_message = "Please select a country to view options."

  def apply(request, query, values)
    query.where(city: values.select { |k, v| v }.keys)
  end

  def options
    cities_for_countries countries
  end

  def react
    # Check if the user selected a country
    if applied_filters["CourseCountryFilter"].present? && applied_filters["CourseCityFilter"].blank?
      # Get the selected countries, get their cities, and select the first one.
      selected_countries = applied_filters["CourseCountryFilter"].select do |name, selected|
        selected
      end

      # Get the first city
      cities = cities_for_countries(selected_countries.keys)
      first_city = cities.first.first

      # Return the first city as selected
      [[first_city, true]].to_h
    end
  end

  private

  # Get a hash of cities for certain countries
  # Example payload:
  # countries = ["USA", "Japan"]
  def cities_for_countries(countries = [])
    countries
      .map do |country|
        Course.cities.stringify_keys[country]
      end
      .flatten
      .map { |city| [city, city] }
      .to_h
  end

  # Get the value of the selected countries
  def countries
    if applied_filters["CourseCountryFilter"].present?
      applied_filters["CourseCountryFilter"].select { |k, v| v }.keys
    else
      # Course.countries
      []
    end
  end
end
