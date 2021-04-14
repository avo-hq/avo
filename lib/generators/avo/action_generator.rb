require "rails/generators"

module Generators
  module Avo
    class ActionGenerator < Rails::Generators::NamedBase
      source_root File.expand_path("templates", __dir__)
      namespace "avo:action"

      def create_resource_file
        template "action.tt", "app/avo/actions/#{singular_name}.rb"
      end
    end
  end
end
