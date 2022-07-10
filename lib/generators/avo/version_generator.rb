require "rails/generators"
require "fileutils"

module Generators
  module Avo
    class VersionGenerator < ::Rails::Generators::Base
      namespace "avo:version"

      def handle
        if defined? ::Avo::Engine
          puts "Avo #{::Avo.configuration.license} #{::Avo::VERSION}"
        else
          puts "Avo not installed."
        end
      end
    end
  end
end
