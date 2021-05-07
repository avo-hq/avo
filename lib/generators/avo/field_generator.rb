require "rails/generators"

module Generators
  module Avo
    class FieldGenerator < ::Rails::Generators::NamedBase
      source_root File.expand_path("templates", __dir__)

      namespace "avo:field"
      desc "Add a custom Avo field to your project."

      def handle
        directory "field/components", "app/components/avo/fields/#{singular_name}_field"
        template "field/%singular_name%_field.rb.tt", "app/avo/fields/#{singular_name}_field.rb"
      end
    end
  end
end
