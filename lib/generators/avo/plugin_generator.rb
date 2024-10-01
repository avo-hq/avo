require_relative "named_base_generator"

module Generators
  module Avo
    class PluginGenerator < NamedBaseGenerator
      PATH = "app/avo/plugins"
      source_root File.expand_path("templates", __dir__)

      class_option :type, type: :string, default: "blank"

      namespace "avo:plugin"

      def create_resource_file
        raise "Invalid plugin type '#{options[:type]}'" unless plugin_types.include? options[:type]

        if blank_plugin?
          create_blank_plugin
        elsif field_plugin?
          create_field_plugin
        else
          say "Invalid plugin type"
        end
      end

      no_tasks do
        def blank_plugin? = options[:type] == "blank"
        def field_plugin? = options[:type] == "field"
        def full_name
          if field_plugin?
            return file_name if file_name.ends_with?("_field")
            "#{file_name}_field"
          else
            file_name
          end
        end
        def name_without_field = full_name["_field"] = ""
        def full_class_name = full_name.classify
        def module_name = full_class_name
        def full_path = Rails.root.join(PATH, full_name).to_s
        def lib_dir = Rails.root.join(full_path, "lib", full_name).to_s
        def railtie_or_engine = File.exist?("#{lib_dir}/railtie.rb") ? "#{lib_dir}/railtie.rb" : "#{lib_dir}/engine.rb"

        def create_blank_plugin
          # Run the rails plugin commang
          # system "rails plugin new #{full_path}"

          inject_registration_code
        end

        def create_field_plugin
          # Run the rails plugin command
          system "rails plugin new #{full_path} --mountable"

          inject_registration_code

          # add field class
          template "plugins/field/field.tt", "#{lib_dir}/fields/#{full_name}.rb"

          # add components
          directory "plugins/field/components", "#{lib_dir}/fields/#{full_name}/"

          # add gem to Gemfile
          # gem file_name, path: full_path
        end

        def inject_registration_code
          insert_into_file railtie_or_engine, engine_code_for(options[:type]), after: "isolate_namespace #{full_class_name}\n"
        end

        def engine_code_for(type)
          # add field registration
          field_code = "\n        Avo.plugin_manager.register_field :#{file_name}, #{class_name}::Fields::#{full_class_name.classify}"

          # add initializer and hook
          <<-METHOD

    initializer "#{file_name}.init" do
      ActiveSupport.on_load(:avo_boot) do
        Avo.plugin_manager.register :#{file_name}

        # Do things while the app boots#{field_code if field_plugin?}
      end
    end
            METHOD
        end

        def plugin_types
          %w[field blank]
        end
      end
    end
  end
end
