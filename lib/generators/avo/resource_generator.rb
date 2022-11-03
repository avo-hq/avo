require_relative "named_base_generator"

module Generators
  module Avo
    class ResourceGenerator < NamedBaseGenerator
      source_root File.expand_path("templates", __dir__)

      namespace "avo:resource"

      class_option "model-class",
        type: :string,
        required: false,
        desc: "The name of the model."

      def create
        template "resource/resource.tt", "app/avo/resources/#{resource_name}.rb"
        template "resource/controller.tt", "app/controllers/avo/#{controller_name}.rb"
      end

      def resource_class
        "#{class_name}Resource"
      end

      def controller_class
        "Avo::#{class_name.camelize.pluralize}Controller"
      end

      def resource_name
        "#{singular_name}_resource"
      end

      def controller_name
        "#{plural_name}_controller"
      end

      def current_models
        ActiveRecord::Base.connection.tables.map do |model|
          model.capitalize.singularize.camelize
        end
      end

      def class_from_args
        @class_from_args ||= options[:model_class]&.capitalize
      end

      def model_class_from_args
        "\n  self.model_class = ::#{class_from_args}" if class_from_args.present?
      end

      private

      def model_class
        @model_class ||= class_from_args || singular_name
      end

      def model
        @model ||= model_class.classify.safe_constantize
      end

      def model_db_columns
        @model_db_columns ||= model.columns_hash.reject { |name, _| db_columns_to_ignore.include? name }
      end

      def db_columns_to_ignore
        %w[id encrypted_password reset_password_token reset_password_sent_at remember_created_at created_at updated_at]
      end

      def reflections
        @reflections ||= model.reflections.reject do |name, _|
          reflections_sufixes_to_ignore.include?(name.split("_").pop) || reflections_to_ignore.include?(name)
        end
      end

      def reflections_sufixes_to_ignore
        %w[blob blobs tags]
      end

      def reflections_to_ignore
        %w[taggings]
      end

      def attachments
        @attachments ||= reflections.select do |_, reflection|
          reflection.options[:class_name] == "ActiveStorage::Attachment"
        end
      end

      def tags
        @tags ||= reflections.select { |_, reflection| reflection.options[:as] == :taggable }
      end

      def associations
        @associations ||= reflections.reject { |key| attachments.key?(key) || tags.key?(key) }
      end

      def fields
        @fields ||= {}
      end

      def invoked_by_model_generator?
        @options.dig("from_model_generator")
      end

      def generate_fields
        return generate_fields_from_args if invoked_by_model_generator?

        if model.blank?
          puts "Can't generate fields from model. '#{model_class}.rb' not found!"
          return
        end

        fields_from_model_db_columns
        fields_from_model_enums
        fields_from_model_attachements
        fields_from_model_associations
        fields_from_model_tags

        generated_fields_template
      end

      def generated_fields_template
        return if fields.blank?

        fields_string = "\n  # Fields generated from the model"

        fields.each do |field_name, field_options|
          options = ""
          field_options[:options].each { |k, v| options += ", #{k}: #{v}" } if field_options[:options].present?

          fields_string += "\n  #{field_string field_name, field_options[:field], options}"
        end

        fields_string
      end

      def field_string(name, type, options)
        "field :#{name}, as: :#{type}#{options}"
      end

      def generate_fields_from_args
        @args.each do |arg|
          name, type = arg.split(":")
          type = "string" if type.blank?
          fields[name] = field(name, type.to_sym)
        end

        generated_fields_template
      end

      def fields_from_model_tags
        tags.each do |name, _|
          fields[(remove_last_word_from name).pluralize] = {field: "tags"}
        end
      end

      def fields_from_model_associations
        associations.each do |name, association|
          fields[name] = associations_mapping[association.class]

          if association.is_a? ActiveRecord::Reflection::ThroughReflection
            fields[name][:options][:through] = ":#{association.options[:through]}"
          end
        end
      end

      def fields_from_model_attachements
        attachments.each do |name, attachment|
          fields[remove_last_word_from name] = attachments_mapping[attachment.class]
        end
      end

      # "hello_world_hehe".split('_') => ['hello', 'world', 'hehe']
      # ['hello', 'world', 'hehe'].pop => ['hello', 'world']
      # ['hello', 'world'].join('_') => "hello_world"
      def remove_last_word_from(snake_case_string)
        snake_case_string = snake_case_string.split("_")
        snake_case_string.pop
        snake_case_string.join("_")
      end

      def fields_from_model_enums
        model.defined_enums.each_key do |enum|
          fields[enum] = {
            field: "select",
            options: {
              enum: "::#{model_class.capitalize}.#{enum.pluralize}"
            }
          }
        end
      end

      def fields_from_model_db_columns
        model_db_columns.each do |name, data|
          fields[name] = field(name, data.type)
        end
      end

      def field(name, type)
        names_mapping[name.to_sym] || fields_mapping[type.to_sym] || {field: "text"}
      end

      def associations_mapping
        {
          ActiveRecord::Reflection::BelongsToReflection => {
            field: "belongs_to"
          },
          ActiveRecord::Reflection::HasOneReflection => {
            field: "has_one"
          },
          ActiveRecord::Reflection::HasManyReflection => {
            field: "has_many"
          },
          ActiveRecord::Reflection::ThroughReflection => {
            field: "has_many",
            options: {
              through: ":..."
            }
          },
          ActiveRecord::Reflection::HasAndBelongsToManyReflection => {
            field: "has_and_belongs_to_many"
          }
        }
      end

      def attachments_mapping
        {
          ActiveRecord::Reflection::HasOneReflection => {
            field: "file"
          },
          ActiveRecord::Reflection::HasManyReflection => {
            field: "files"
          }
        }
      end

      def names_mapping
        {
          id: {
            field: "id"
          },
          description: {
            field: "textarea"
          },
          gravatar: {
            field: "gravatar"
          },
          email: {
            field: "text"
          },
          password: {
            field: "password"
          },
          password_confirmation: {
            field: "password"
          },
          stage: {
            field: "select"
          },
          budget: {
            field: "currency"
          },
          money: {
            field: "currency"
          },
          country: {
            field: "country"
          }
        }
      end

      def fields_mapping
        {
          primary_key: {
            field: "id"
          },
          string: {
            field: "text"
          },
          text: {
            field: "textarea"
          },
          integer: {
            field: "number"
          },
          float: {
            field: "number"
          },
          decimal: {
            field: "number"
          },
          datetime: {
            field: "datetime"
          },
          timestamp: {
            field: "datetime"
          },
          time: {
            field: "datetime"
          },
          date: {
            field: "date"
          },
          binary: {
            field: "number"
          },
          boolean: {
            field: "boolean"
          },
          references: {
            field: "belongs_to"
          },
          json: {
            field: "code"
          }
        }
      end
    end
  end
end
