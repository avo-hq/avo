class Avo::CoursesController < Avo::ResourcesController
  def cities
    render json: get_cities(params[:country])
  end

  def after_destroy_path
    avo.new_resources_course_path
  end

  def create_success_message
    "#{@model.class.name} created!"
  end

  def create_fail_message
    "#{@model.class.name} not created!"
  end

  def update_success_message
    "#{@model.class.name} updated!"
  end

  def update_fail_message
    "#{@model.class.name} not updated!"
  end

  def destroy_success_message
    "#{@model.class.name} destroyed for ever!"
  end

  private

  def get_cities(country)
    return [] unless Course.countries.include?(country)

    Course.cities[country.to_sym]
  end
end
