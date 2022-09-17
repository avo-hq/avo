require_relative "base_generator"

module Generators
  module Avo
    class LocalesGenerator < BaseGenerator
      source_root File.expand_path("templates", __dir__)

      namespace "avo:locales"
      desc "Add Avo locale files to your project."

      def create_files
        directory File.join(__dir__, "templates", "locales"), "config/locales"
      end
    end
  end
end
