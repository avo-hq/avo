class Avo::CoursesController < Avo::ResourcesController
  def cities
    render json: get_cities(params[:country])
  end

  private

  def get_cities(country)
    return [] unless Course.countries.include?(country)

    Course.cities[country.to_sym]
  end
end
