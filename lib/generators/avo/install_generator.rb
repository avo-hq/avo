require_relative "base_generator"

module Generators
  module Avo
    class InstallGenerator < BaseGenerator
      source_root File.expand_path("templates", __dir__)

      namespace "avo:install"
      desc "Creates an Avo initializer adds the route to the routes file."
      class_option :path, type: :string, default: "avo"
      class_option :"app-id", type: :string

      def create_initializer_file
        route "mount_avo"

        template "initializer/avo.tt", "config/initializers/avo.rb"

        create_resources
      end

      no_tasks do
        def create_resources
          if defined?(User).present?
            Rails::Generators.invoke("avo:resource", ["user", "-q"], {destination_root: Rails.root})
          end
        end

        def app_id
          options[:"app-id"]
        end

        if defined?(Account) && Account.is_a?(ActiveRecord::Base)
          Rails::Generators.invoke("avo:resource", ["account", "-q"], {destination_root: Rails.root })
        end
      end
    end
  end
end
