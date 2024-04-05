require_relative "named_base_generator"
require_relative "concerns/parent_controller"
require_relative "concerns/override_controller"

module Generators
  module Avo
    class ControllerGenerator < NamedBaseGenerator
      include Concerns::ParentController
      include Concerns::OverrideController

      source_root File.expand_path("templates", __dir__)

      namespace "avo:controller"

      def create
        return if override_controller?

        template "resource/controller.tt", "app/controllers/avo/#{controller_name}.rb"
      end

      private

      def controller_name
        "#{plural_name}_controller"
      end

      def controller_class
        "Avo::#{class_name.camelize.pluralize}Controller"
      end
    end
  end
end
