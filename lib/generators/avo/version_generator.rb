require "rails/generators"

module Generators
  module Avo
    class VersionGenerator < ::Rails::Generators::Base
      namespace "avo:version"

      def handle
        if defined? ::Avo::Engine
          output "Avo #{::Avo.configuration.license} #{::Avo::VERSION}"
        else
          output "Avo not installed."
        end
      end

      private

      def output(message)
        puts message unless options["quiet"]
      end
    end
  end
end
