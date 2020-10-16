require 'rails/generators/base'

class InstallGenerator < Rails::Generators::Base
  source_root File.expand_path('templates', __dir__)

  namespace 'avo:install'
  desc 'Creates an Avo initializer adds the route to the routes file.'
  class_option :path, type: :string, default: 'avo'

  def create_initializer_file
    route 'mount Avo::Engine => Avo.configuration.root_path'

    template 'initializer.rb', 'config/initializers/avo.rb'
  end
end
