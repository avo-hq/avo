require_relative "named_base_generator"

module Generators
  module Avo
    class ActionGenerator < NamedBaseGenerator
      source_root File.expand_path("templates", __dir__)

      class_option :standalone, type: :boolean, default: false
      class_option :name, type: :string

      namespace "avo:action"

      def create_resource_file
        template "action.tt", "app/avo/actions/#{singular_name}.rb"
      end

      def configuration_options
        configuration = "  self.name = \"#{options[:name] || name.titleize}\""
        configuration += "\n  self.standalone = true" if options[:standalone]

        configuration
      end
    end
  end
end
