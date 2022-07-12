require_relative "named_base_generator"

module Generators
  module Avo
    class FieldGenerator < NamedBaseGenerator
      source_root File.expand_path("templates", __dir__)

      namespace "avo:field"
      desc "Add a custom Avo field to your project."

      def handle
        directory "field/components", "#{::Avo.configuration.view_component_path}/avo/fields/#{singular_name}_field"
        template "field/%singular_name%_field.rb.tt", "app/avo/fields/#{singular_name}_field.rb"
      end
    end
  end
end
