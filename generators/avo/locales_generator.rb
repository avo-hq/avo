require 'rails/generators/base'

class Generators::InstallGenerator < ::Rails::Generators::Base
  source_root File.expand_path('templates', __dir__)

  namespace 'avo:locales'
  desc 'Creates an Avo initializer adds the route to the routes file.'

  def create_files
    template 'locales/avo.en.yml', 'config/locales/avo.en.yml'
  end
end
