require "rails/generators"
require "fileutils"

module Generators
  module Avo
    class VersionGenerator < ::Rails::Generators::Base
      namespace "avo:version"

      def handle
        if defined? ::Avo::Engine
          puts "Avo #{::Avo.configuration.license} #{::Avo::VERSION}" unless options["quiet"]
        else
          puts "Avo not installed." unless options["quiet"]
        end
      end
    end
  end
end
