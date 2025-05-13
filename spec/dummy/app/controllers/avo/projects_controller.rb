class Avo::ProjectsController < Avo::ResourcesController
  def async_test
    sleep 5
    render turbo_stream: turbo_stream.replace("async_test", "async value")
  end
end
