require "rails/generators"

module Generators
  module Avo
    class ResourceGenerator < ::Rails::Generators::NamedBase
      source_root File.expand_path("templates", __dir__)

      namespace "avo:resource"

      def create
        template "resource/resource.tt", "app/avo/resources/#{resource_name}.rb"
        template "resource/controller.tt", "app/controllers/avo/#{controller_name}.rb"

        # Show a warning if the model doesn't exists
        say("We couldn't find the #{class_name} model in your codebase. You should have one present for Avo to display the resource.", :yellow) unless current_models.include? class_name
      end

      def resource_class
        "#{class_name}Resource"
      end

      def controller_class
        "Avo::#{plural_name.humanize}Controller"
      end

      def resource_name
        "#{singular_name}_resource"
      end

      def controller_name
        "#{plural_name}_controller"
      end

      def current_models
        ActiveRecord::Base.connection.tables.map do |model|
          model.capitalize.singularize.camelize
        end
      end
    end
  end
end
