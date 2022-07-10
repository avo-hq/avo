require_relative "named_base_generator"

module Generators
  module Avo
    class ResourceGenerator < NamedBaseGenerator
      source_root File.expand_path("templates", __dir__)

      namespace "avo:resource"

      def create
        template "resource/resource.tt", "app/avo/resources/#{resource_name}.rb"
        template "resource/controller.tt", "app/controllers/avo/#{controller_name}.rb"
      end

      def resource_class
        "#{class_name}Resource"
      end

      def controller_class
        "Avo::#{class_name.camelize.pluralize}Controller"
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
