class Generators::ControllerGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('templates', __dir__)

  namespace 'avo:controller'

  def create
    template 'resource/%plural_name%_controller.tt', "app/controllers/avo/#{controller_name}.rb"
  end

  def controller_name
    "#{plural_name}_controller"
  end
end
