class HomeController < ApplicationController
  def index
  end

  def trigger_course_update
    CourseResource.reload_resource id: 280

    render plain: :ok
  end
end
