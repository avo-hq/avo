# require 'rails/generators/base'

class ResourceGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('templates', __dir__)

  argument :additional_fields, type: :hash, required: false
  class_option :'generate-fields', type: :boolean, required: false, default: false
  class_option :'model-class', type: :string, required: false

  namespace 'avo:resource'

  def create_resource_file
    @model_class = options[:'model-class'] ? options[:'model-class'] : singular_name
    @fields = fields
    template 'resource.rb', "app/avo/resources/#{singular_name}.rb"
  end

  private
    def fields
      fields = {}
      fields = fields.merge(generated_params) if options[:'generate-fields']
      fields = fields.merge(additional_params) if !additional_fields.nil?
      fields = fields.except('id') if fields.key?('id')

      puts fields
      fields
    end

    def generated_params
      columns_with_type = {}
      begin
        model = @model_class.classify.constantize
        model.columns_hash.each { |k, v| columns_with_type[k] = v.type }
        puts columns_with_type
      rescue NameError => e
        puts 'Name error occurs. There is no ' + @model_class.classify + ' model.'
      rescue => e
        puts 'Other error occured.'
      end

      result = {}
      if !columns_with_type.empty?
        columns_with_type.each do |fieldname, fieldtype|
          result[fieldname] = field(fieldname, fieldtype)
        end
      end

      result
    end

    def additional_params
      result = {}

      additional_fields.each do |fieldname, fieldtype|
        if avo_fields.include? fieldtype
          result[fieldname] = { field: fieldtype, }
        else
          result[fieldname] = field(fieldname, fieldtype)
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

    def field(fieldname, fieldtype)
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
      }

      return { field: 'password' } if (fieldname.include?('pass') || fieldname.include?('password')) && !fieldname.include?('reset')
      return name_mappings[fieldname.to_sym] if name_mappings.key?(fieldname.to_sym)
      return field_mappings[fieldtype.to_sym] if field_mappings.key?(fieldtype.to_sym)
      { field: 'text', }
    end
end
