# require 'rails/generators/base'

class ResourceGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('templates', __dir__)

  desc 'Creates an Avo resource'

  argument :additional_fields, type: :hash, required: false
  class_option :'generate-fields', type: :boolean, required: false, default: false, desc: 'Looks for fields in the model and generates them.'
  class_option :'model-class', type: :string, required: false, desc: 'The name of the model.'

  namespace 'avo:resource'

  def create_resource_file
    @model_class = options[:'model-class'] ? options[:'model-class'] : singular_name
    template 'resource.rb', "app/avo/resources/#{singular_name}.rb"
  end

  private
    def generate_initializer
      initializerString = ''

      initializerString = "\n        @model = " + @model_class if options[:'model-class']

      initializerString
    end

    def generate_fields
      fields = {}
      fields = fields.merge(generate_params_from_model) if options[:'generate-fields']
      fields = fields.merge(generate_select_from_model) if options[:'generate-fields']
      fields = fields.merge(generate_additional_params_from_argument) if !additional_fields.nil?

      fieldsString = ''
      if fields.present?
        fields.each do |field_name, field_options|
          options = ''
          if field_options[:options].present?
            field_options[:options].each { |k, v| options += ', ' + k.to_s + ': ' + v }
          end

          fieldsString += "\n        " + field_options[:field] + ' :' + field_name + options
        end
      end

      fieldsString
    end

    def generate_select_from_model
      enums = []
      begin
        model = @model_class.classify.safe_constantize
        model.defined_enums.each { |k, v| enums.push(k) }
      rescue NameError => e
        puts 'Name error occurs. There is no ' + @model_class.classify + ' model.'
      rescue => e
        puts 'Other error occured.'
      end

      results = {}
      if enums.present?
        enums.each { |enum| results[enum] = {
          field: 'select',
          options: {
            enum: '::' + @model_class.capitalize + '.' + enum.pluralize
          },
        } }
      end

      puts results

      results
    end

    def generate_params_from_model
      columns_with_type = {}
      begin
        model = @model_class.classify.safe_constantize
        model.columns_hash.each { |k, v| columns_with_type[k] = v.type }
      rescue NameError => e
        puts 'Name error occurs. There is no ' + @model_class.classify + ' model.'
      rescue => e
        puts 'Other error occured.'
      end

      result = {}
      if columns_with_type.present?
        columns_with_type.each do |field_name, field_type|
          result[field_name] = field(field_name, field_type)
        end
      end

      # ignore some fields from model
      result = result.except('id') if result.key?('id')
      result = result.except('encrypted_password') if result.key?('encrypted_password')
      result = result.except('reset_password_token') if result.key?('reset_password_token')
      result = result.except('reset_password_sent_at') if result.key?('reset_password_sent_at')
      result = result.except('remember_created_at') if result.key?('remember_created_at')
      result = result.except('created_at') if result.key?('created_at')
      result = result.except('updated_at') if result.key?('updated_at')

      result
    end

    def generate_additional_params_from_argument
      result = {}

      additional_fields.each do |field_name, field_type|
        if avo_fields.include? field_type
          result[field_name] = { field: field_type, }
        else
          result[field_name] = field(field_name, field_type)
        end
      end

      result
    end

    def avo_fields
      avo_fields = []

      avo_fields_files = Dir[Avo::Engine.root.join('lib', 'avo', 'app', 'fields').to_s + '/*.rb']

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

    def field(field_name, field_type)
      field_mappings = {
        primary_key: {
          field: 'id',
        },
        string: {
          field: 'text',
        },
        text: {
          field: 'textarea',
        },
        integer: {
          field: 'number',
        },
        float: {
          field: 'number',
        },
        decimal: {
          field: 'number',
        },
        datetime: {
          field: 'datetime',
        },
        timestamp: {
          field: 'datetime',
        },
        time: {
          field: 'datetime',
        },
        date: {
          field: 'date',
        },
        binary: {
          field: 'number',
        },
        boolean: {
          field: 'boolean',
        },
        references: {
          field: 'belongs_to',
        },
        json: {
          field: 'code',
        },
      }

      name_mappings = {
        id: {
          field: 'id',
        },
        description: {
          field: 'textarea',
        },
        gravatar: {
          field: 'gravatar',
        },
        email: {
          field: 'text',
        },
        password: {
          field: 'password',
        },
        password_confirmation: {
          field: 'password',
        },
        stage: {
          field: 'select',
        },
        budget: {
          field: 'currency',
        },
        money: {
          field: 'currency',
        },
        country: {
          field: 'country',
        },
      }

      return name_mappings[field_name.to_sym] if name_mappings.key?(field_name.to_sym)
      return field_mappings[field_type.to_sym] if field_mappings.key?(field_type.to_sym)
      { field: 'text', }
    end
end
