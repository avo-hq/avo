require "rails/generators"
require "fileutils"

module Generators
  module Avo
    class VersionGenerator < ::Rails::Generators::Base
      namespace "avo:version"

      def handle
        if defined? ::Avo::Engine
          output "Avo #{::Avo.configuration.license} #{::Avo::VERSION}", options
        else
          output "Avo not installed.", options
        end
      end

      private

      def output(message, options)
        puts message unless options["quiet"]
      end
    end
  end
end
