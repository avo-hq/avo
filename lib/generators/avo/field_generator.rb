require_relative "named_base_generator"

module Generators
  module Avo
    class FieldGenerator < NamedBaseGenerator
      source_root File.expand_path("templates", __dir__)

      namespace "avo:field"
      desc "Add a custom Avo field to your project."

      class_option "field-template", type: :string, required: false

      def handle
        return field_from_template if field_template.present?

        directory "field/components", destination_components_path
        template "field/%singular_name%_field.rb.tt", destination_field_path
      end

      no_tasks do
        def field_from_template
          if !File.file? ::Avo::Engine.root.join(template_field_path)
            return say("Failed to find the `#{field_template}` template field.", :yellow)
          end

          if !Dir.exist? ::Avo::Engine.root.join(template_components_path)
            return say("Failed to find the `#{field_template}` template field components.", :yellow)
          end

          directory ::Avo::Engine.root.join(template_components_path), destination_components_path
          copy_file ::Avo::Engine.root.join(template_field_path), destination_field_path

          Dir.glob("#{destination_components_path}/*").push(destination_field_path).each do |file|
            modified_content = File.read(file).gsub("#{field_template.camelize}Field", "#{singular_name.camelize}Field")

            File.open(file, "w") do |open_file|
              open_file.puts modified_content
            end
          end
        end

        def field_template
          options["field-template"]
        end

        def template_field_path
          "lib/avo/fields/#{field_template}_field.rb"
        end

        def template_components_path
          "app/components/avo/fields/#{field_template}_field"
        end

        def destination_components_path
          "#{::Avo.configuration.view_component_path}/avo/fields/#{singular_name}_field"
        end

        def destination_field_path
          "app/avo/fields/#{singular_name}_field.rb"
        end
      end
    end
  end
end
