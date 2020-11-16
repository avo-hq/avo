# require 'rails/generators/base'

class ResourceGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('templates', __dir__)

  desc 'Creates an Avo resource'

  argument :additional_fields, type: :hash, required: false
  class_option :'generate-fields', type: :boolean, required: false, default: false, desc: 'Looks for fields in the model and generates them.'
  class_option :'model-class', type: :string, required: false, desc: 'The name of the model.'

  namespace 'avo:resource'

  def create_resource_file
    @model = options[:'model-class']
    @model_class = options[:'model-class'] ? options[:'model-class'] : singular_name
    template 'resource.rb', "app/avo/resources/#{singular_name}.rb"
  end

  private
    def generate_initializer
      initializerString = ''

      initializerString = "\n        @model = " + @model if @model.present?

      initializerString
    end

    def generate_fields
      fields = {}
      fields = fields.merge(generate_params_from_model) if options[:'generate-fields']
      fields = fields.merge(generate_additional_params_from_argument) if !additional_fields.nil?
      fields = fields.except('id') if fields.key?('id')
      fields = fields.except('encrypted_password') if fields.key?('encrypted_password')
      fields = fields.except('reset_password_token') if fields.key?('reset_password_token')
      fields = fields.except('reset_password_sent_at') if fields.key?('reset_password_sent_at')
      fields = fields.except('remember_created_at') if fields.key?('remember_created_at')

      fieldsString = ''
      if fields.present?
        fields.each do |field_name, fieldoptions|
          fieldsString += "\n        " + fieldoptions[:field] + ' :' + field_name
        end
      end

      fieldsString
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
