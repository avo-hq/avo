require_relative "base_generator"

module Generators
  module Avo
    class RulesGenerator < BaseGenerator
      source_root File.expand_path("templates", __dir__)

      namespace "avo:rules"

      def create_resource_file
        template "rules/avo.tt", ".cursor/rules/avo.mdc"
      end
    end
  end
end
