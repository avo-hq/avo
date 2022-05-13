require "rails/generators"

module Generators
  module Avo
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)

      namespace "avo:install"
      desc "Creates an Avo initializer adds the route to the routes file."
      class_option :path, type: :string, default: "avo"

      def create_initializer_file
        route "mount Avo::Engine, at: Avo.configuration.root_path"

        template "initializer/avo.tt", "config/initializers/avo.rb"
        template "locales/avo.en.yml", "config/locales/avo.en.yml"
        template "locales/avo.nb-NO.yml", "config/locales/avo.nb-NO.yml"
        template "locales/avo.pt-BR.yml", "config/locales/avo.pt-BR.yml"
        template "locales/avo.ro.yml", "config/locales/avo.ro.yml"
      end
    end
  end
end
