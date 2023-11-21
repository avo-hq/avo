require_relative "base_generator"

module Generators
  module Avo
    class EjectGenerator < BaseGenerator
      class_option :partial,
        desc: "The partial to eject. Example: ':logo', 'app/views/layouts/avo/application.html.erb'",
        type: :string,
        required: false

      class_option :component,
        desc: "The component to eject. Example: 'Avo::Index::TableRowComponent', 'avo/index/table_row_component'",
        type: :string,
        required: false

      class_option :scope,
        desc: "The scope of the component. Example: 'users', 'admins'",
        type: :string,
        required: false

      class_option "field-components",
        desc: "The field components to eject. Example: 'trix', 'text'",
        type: :string,
        required: false

      class_option :view,
        desc: "The view of the component to eject when using --field-component option. Example: 'index', 'show'",
        type: :string,
        required: false

      source_root ::Avo::Engine.root

      namespace "avo:eject"

      TEMPLATES = {
        logo: "app/views/avo/partials/_logo.html.erb",
        head: "app/views/avo/partials/_head.html.erb",
        header: "app/views/avo/partials/_header.html.erb",
        footer: "app/views/avo/partials/_footer.html.erb",
        pre_head: "app/views/avo/partials/_pre_head.html.erb",
        scripts: "app/views/avo/partials/_scripts.html.erb",
        sidebar_extra: "app/views/avo/partials/_sidebar_extra.html.erb",
        profile_menu_extra: "app/views/avo/partials/_profile_menu_extra.html.erb",
      }

      def handle
        if options[:partial].present?
          eject_partial
        elsif options[:component].present?
          eject_component
        elsif options["field-components"].present?
          eject_field_components
        else
          say "Please specify a partial or a component to eject.\n" \
              "Examples: rails g avo:eject --partial :logo\n" \
              "          rails g avo:eject --partial app/views/layouts/avo/application.html.erb\n" \
              "          rails g avo:eject --component Avo::Index::TableRowComponent\n" \
              "          rails g avo:eject --component avo/index/table_row_component\n" \
              "          rails g avo:eject --field-components trix\n" \
              "          rails g avo:eject --field-components trix --scope users\n" \
              "          rails g avo:eject --field-components text --scope users --view edit\n" \
              "          rails g avo:eject --component Avo::Views::ResourceIndexComponent --scope users\n" \
              "          rails g avo:eject --component avo/views/resource_index_component --scope users", :yellow
        end
      end

      no_tasks do
        def path_to_sym(filename)
          template_id = filename.dup
          template_id[0] = ""
          template_id.to_sym
        end

        def path_exists?(path)
          path.present? && File.file?(::Avo::Engine.root.join(path))
        end

        def dir_exists?(path)
          path.present? && Dir.exist?(::Avo::Engine.root.join(path))
        end

        def eject(path, dest_path = nil, is_directory: false)
          method = is_directory ? :directory : :copy_file

          send method, ::Avo::Engine.root.join(path), ::Rails.root.join(dest_path || path)
        end

        def eject_partial
          if options[:partial].starts_with?(":")
            template_id = path_to_sym options[:partial]
            template_path = TEMPLATES[template_id]

            if path_exists? template_path
              return unless confirm_ejection_on template_path
              eject template_path
            else
              say("Failed to find the `#{template_id.to_sym}` template.", :yellow)
            end
          elsif path_exists? options[:partial]
            return unless confirm_ejection_on template_path
            eject options[:partial]
          else
            say("Failed to find the `#{options[:partial]}` template.", :yellow)
          end
        end

        def eject_component(component_to_eject = options[:component], confirmation: true)
          # Underscore the component name
          # Example: Avo::Views::ResourceIndexComponent => avo/views/resource_index_component
          component = component_to_eject.underscore

          # Get the component path for both, the rb and erb files
          rb, erb = ["app/components/#{component}.rb", "app/components/#{component}.html.erb"]

          # Return if one of the components doesn't exist
          if !path_exists?(rb) || !path_exists?(erb)
            return say("Failed to find the `#{component_to_eject}` component.", :yellow)
          end

          # Add the scope to the component if it's possible
          if add_scope? component
            component = if component.starts_with?("avo/views/")
              component.gsub("avo/views/", "avo/views/#{options[:scope].underscore}/")
            elsif component.starts_with?("avo/fields/")
              component.gsub("avo/fields/", "avo/fields/#{options[:scope].underscore}/")
            end
            added_scope = true
          end

          # Confirm the ejection
          if confirmation
            return if !confirm_ejection_on(component.camelize)
          end

          # Get the destination path for both, the rb and erb files
          dest_rb = "#{::Avo.configuration.view_component_path}/#{component}.rb"
          dest_erb = "#{::Avo.configuration.view_component_path}/#{component}.html.erb"

          # Eject the component
          eject rb, dest_rb
          eject erb, dest_erb

          # Remame the component class if scope was added
          # Example: Avo::Views::ResourceIndexComponent => Avo::Views::Admins::ResourceIndexComponent
          if added_scope
            [dest_rb, dest_erb].each do |path|
              if component.starts_with?("avo/views/")
                modified_content = File.read(path).gsub("Avo::Views::", "Avo::Views::#{options[:scope].camelize}::")
              elsif component.starts_with?("avo/fields/")
                modified_content = File.read(path).gsub("#{options["field-components"].camelize}Field", "#{options[:scope].camelize}::#{options["field-components"].camelize}Field")
              end

              File.open(path, "w") do |file|
                file.puts modified_content
              end
            end

            if component.starts_with?("avo/views/")
              say "You can now use this component on any resource by configuring the 'self.components' option.\n" \
                  "  self.components = {\n" \
                  "    #{component.split("/").last}: #{component.camelize}\n" \
                  "  }", :green
            elsif component.starts_with?("avo/fields/")
              say "You can now use this component on any field by configuring the 'components' option.\n" \
                  "  field :name, as: :#{options["field-components"]}, components: {\n" \
                  "    #{component.split("/").last}: #{component.camelize}\n" \
                  "  }", :green
            end
          end
        end

        def eject_field_components
          # Check if the field exists
          field_path = "lib/avo/fields/#{options["field-components"]}_field.rb"
          return say("Failed to find the `#{options["field-components"]}` field.", :yellow) if !path_exists?(field_path)

          # Eject single component if view is specified
          if options[:view].present?
            return eject_component "Avo::Fields::#{options["field-components"].camelize}Field::#{options[:view].camelize}Component"
          end

          # Check if the field components directory exist
          components_path = "app/components/avo/fields/#{options["field-components"]}_field"
          return say("Failed to find the `#{options["field-components"]}` field components.", :yellow) if !dir_exists?(components_path)

          # Build the destination path for the components directory add the scope
          destination_components_path = "#{::Avo.configuration.view_component_path}/#{components_path.gsub("app/components/", "")}"

          if options[:scope].present?
            destination_components_path = destination_components_path.gsub("avo/fields/", "avo/fields/#{options[:scope].underscore}/")
          end

          # Confirm the ejection
          confirm_ejection_on destination_components_path, is_directory: true

          # Eject the components directory
          eject components_path, destination_components_path, is_directory: true

          # Rename the component classes if scope was added
          if options[:scope].present?
            Dir.glob("#{destination_components_path}/*").each do |file|
              modified_content = File.read(file).gsub("#{options["field-components"].camelize}Field", "#{options[:scope].camelize}::#{options["field-components"].camelize}Field")

              File.open(file, "w") do |open_file|
                open_file.puts modified_content
              end
            end
          end
        end

        def confirm_ejection_on(path, is_directory: false)
          say("By ejecting the '#{path}'#{" directory" if is_directory} \033[1myou'll take on the responsibility for maintain it.", :yellow)
          yes?("Are you sure you want to eject the '#{path}'#{" directory" if is_directory}? [y/N]", :yellow)
        end

        def add_scope?(component)
          (component.starts_with?("avo/views/") || component.starts_with?("avo/fields/")) && options[:scope].present?
        end
      end
    end
  end
end
