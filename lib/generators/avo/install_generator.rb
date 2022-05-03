require "rails/generators"

module Generators
  module Avo
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)

      namespace "avo:install"
      desc "Creates an Avo initializer adds the route to the routes file."
      class_option :path, type: :string, default: "avo"

      def create_initializer_file
        # route "mount Avo::Engine, at: Avo.configuration.root_path"

        # template "initializer/avo.tt", "config/initializers/avo.rb"
        # template "locales/avo.en.yml", "config/locales/avo.en.yml"

        inject_into_file Rails.root.join("config", "initializers", "avo.rb"), before: "config.root_path" do <<-'RUBY'
config.token = '123'
  RUBY
        end
      end
    end
  end
end
