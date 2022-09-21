# frozen_string_literal: true

require_relative 'named_base_generator'

module Generators
  module Avo
    class ResourceGenerator < NamedBaseGenerator
      source_root File.expand_path('templates', __dir__)

      namespace 'avo:resource'

      argument :additional_fields, type: :hash, required: false
      class_option :'generate-fields', type: :boolean, required: false, default: false,
        desc: 'Looks for fields in the model and generates them.'
      class_option :'model-class', type: :string, required: false, desc: 'The name of the model.'

      def create
        template 'resource/resource.tt', "app/avo/resources/#{resource_name}.rb"
        template 'resource/controller.tt', "app/controllers/avo/#{controller_name}.rb"
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

      def model_class_from_args
        class_from_args = options[:'model-class']

        "\n  self.model_class = ::#{class_from_args}" if class_from_args.present?
      end

      private

      def model_class
        @model_class ||= options[:'model-class'] || singular_name
      end

      def model
        @model ||= model_class.classify.safe_constantize
      end

      def reflections
        @reflections ||= model.reflections.reject { |name, _| model_reflections_to_ignore.include? name.split('_').pop }
      end

      def generate_fields
        return unless options[:'generate-fields'] || additional_fields.present?

        fields = {}

        if options[:'generate-fields']
          if model.present?
            fields =
              fields
              .merge generate_params_from_model
              .merge generate_select_from_model
              .merge generate_attachements_from_model
          else
            puts "Can't generate fields from model. '#{model_class}.rb' not found!"
          end
        end

        fields = fields.merge generate_additional_params_from_argument if additional_fields.present?

        generated_fields_template fields if fields.present?

        # rescue StandardError => e
        #   puts 'Other error occured.' # TODO: better error message
      end

      def generated_fields_template(fields)
        fields_string = "\n  # Generated fields from model"

        fields.each do |field_name, field_options|
          options = ''
          field_options[:options].each { |k, v| options += ", #{k}: #{v}" } if field_options[:options].present?

          fields_string += "\n  #{field_string field_name, field_options[:field], options}"
        end

        fields_string
      end

      def field_string(name, type, options)
        "field :#{name}, as: :#{type}#{options}"
      end

      def generate_attachements_from_model
        results = {}

        reflections.each do |name, reflection|
          next if name == 'taggings'

          if reflection.options[:as] == :taggable
            results[(remove_last_word_from_name name).pluralize] = { field: 'tags' }

            next
          end

          if reflection.options[:class_name] == 'ActiveStorage::Attachment'
            results[remove_last_word_from_name name] = attachments_mapping[reflection.class]

            next
          end

          results[name] = associations_mapping[reflection.class]

          if reflection.is_a? ActiveRecord::Reflection::ThroughReflection
            results[name][:options][:through] = ":#{reflection.options[:through]}"
          end
        end

        results
      end

      def model_reflections_to_ignore
        %w[blob blobs tags]
      end

      # "hello_world_hehe".split('_') => ['hello', 'world', 'hehe']
      # ['hello', 'world', 'hehe'].pop => ['hello', 'world']
      # ['hello', 'world'].join('_') => "hello_world"
      def remove_last_word_from_name(name)
        name = name.split('_')
        name.pop
        name.join('_')
      end

      def generate_select_from_model
        results = {}

        enums.each do |enum|
          results[enum] = {
            field: 'select',
            options: {
              enum: "::#{model_class.capitalize}.#{enum.pluralize}"
            }
          }
        end

        results
      end

      def enums
        return [] if model.defined_enums.empty?

        enums = model.defined_enums.keys
      end

      def generate_params_from_model
        columns_type_by_name = {}

        model_columns.each do |name, data|
          columns_type_by_name[name] = field(name, data.type)
        end

        columns_type_by_name
      end

      def model_columns
        model.columns_hash.reject { |name, _| model_fields_to_ignore.include? name }
      end

      def model_fields_to_ignore
        %w[id encrypted_password reset_password_token reset_password_sent_at remember_created_at created_at updated_at]
      end

      def generate_additional_params_from_argument
        result = {}

        additional_fields.each do |name, type|
          result[name] = if avo_fields.include? type
            { field: type }
          else
            field(name, type)
          end
        end

        result
      end

      def avo_fields
        avo_fields = []

        # TODO: check things here
        avo_fields_files = Dir["#{File.join(ENGINE_PATH, 'lib', 'avo', 'app', 'fields')}/*.rb"]

        avo_fields_files.each do |file|
          filename = file.match('[^/]*$').to_s
          if filename.include? 'field'
            avo_fields.push(filename.first(-9))
          else
            avo_fields.push(filename.first(-3))
          end
        end

        avo_fields.delete('')

        avo_fields
      end

      def field(name, type)
        names_mapping[name.to_sym] || fields_mapping[type.to_sym] || { field: 'text' }
      end

      def associations_mapping
        {
          ActiveRecord::Reflection::BelongsToReflection => {
            field: 'belongs_to'
          },
          ActiveRecord::Reflection::HasOneReflection => {
            field: 'has_one'
          },
          ActiveRecord::Reflection::HasManyReflection => {
            field: 'has_many'
          },
          ActiveRecord::Reflection::ThroughReflection => {
            field: 'has_many',
            options: {
              through: ':...'
            }
          },
          ActiveRecord::Reflection::HasAndBelongsToManyReflection => {
            field: 'has_and_belongs_to_many'
          }
        }
      end

      def attachments_mapping
        {
          ActiveRecord::Reflection::HasOneReflection => {
            field: 'file'
          },
          ActiveRecord::Reflection::HasManyReflection => {
            field: 'files'
          }
        }
      end

      def names_mapping
        {
          id: {
            field: 'id'
          },
          description: {
            field: 'textarea'
          },
          gravatar: {
            field: 'gravatar'
          },
          email: {
            field: 'text'
          },
          password: {
            field: 'password'
          },
          password_confirmation: {
            field: 'password'
          },
          stage: {
            field: 'select'
          },
          budget: {
            field: 'currency'
          },
          money: {
            field: 'currency'
          },
          country: {
            field: 'country'
          }
        }
      end

      def fields_mapping
        {
          primary_key: {
            field: 'id'
          },
          string: {
            field: 'text'
          },
          text: {
            field: 'textarea'
          },
          integer: {
            field: 'number'
          },
          float: {
            field: 'number'
          },
          decimal: {
            field: 'number'
          },
          datetime: {
            field: 'datetime'
          },
          timestamp: {
            field: 'datetime'
          },
          time: {
            field: 'datetime'
          },
          date: {
            field: 'date'
          },
          binary: {
            field: 'number'
          },
          boolean: {
            field: 'boolean'
          },
          references: {
            field: 'belongs_to'
          },
          json: {
            field: 'code'
          }
        }
      end
    end
  end
end
