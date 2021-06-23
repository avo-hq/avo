require "rails/generators"

module Generators
  module Avo
    class ActionGenerator < Rails::Generators::NamedBase
      source_root File.expand_path("templates", __dir__)
      class_option :standalone, type: :boolean

      namespace "avo:action"

      def create_resource_file
        type = "resource"

        type = "standalone" if options[:standalone]

        if type == "standalone"
          template "standalone_action.tt", "app/avo/actions/#{singular_name}.rb"
        else
          template "action.tt", "app/avo/actions/#{singular_name}.rb"
        end
      end
    end
  end
end
