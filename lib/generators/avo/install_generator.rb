require 'rails/generators/base'

class InstallGenerator < Rails::Generators::Base
  source_root File.expand_path('templates', __dir__)

  namespace 'avo:install'
  desc 'Creates an Avocado initializer adds the route to the routes file.'
  class_option :path, type: :string, default: 'avocado'

  def create_initializer_file
    route "mount Avocado::Engine => '/#{options[:path]}'"

    template 'initializer.rb', 'config/initializers/avocado.rb'
  end
end
