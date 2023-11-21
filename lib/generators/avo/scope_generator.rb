require_relative "named_base_generator"

module Generators
  module Avo
    class ScopeGenerator < NamedBaseGenerator
      source_root File.expand_path("templates", __dir__)

      namespace "avo:scope"

      def create
        template "scope.tt", "app/avo/scopes/#{singular_name}.rb"
      end
    end
  end
end
