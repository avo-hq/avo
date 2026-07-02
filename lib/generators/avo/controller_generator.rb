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

      # File path under app/controllers/avo/. Pluralizes the last segment only.
      # Example: "galaxy/sector/planet/satellite" -> "galaxy/sector/planet/satellites_controller"
      # File written: app/controllers/avo/galaxy/sector/planet/satellites_controller.rb
      def controller_name
        segments = file_path.split("/")
        segments[-1] = segments[-1].pluralize
        "#{segments.join("/")}_controller"
      end

      # Constant defined inside the file. Pluralizes the last namespace segment only.
      # Example: "Galaxy::Sector::Planet::Satellite" -> "Avo::Galaxy::Sector::Planet::SatellitesController"
      #
      #   class Avo::Galaxy::Sector::Planet::SatellitesController < Avo::ResourcesController
      #   end
      def controller_class
        parts = class_name.split("::").map(&:camelize)
        parts[-1] = parts[-1].pluralize
        "Avo::#{parts.join("::")}Controller"
      end
    end
  end
end
