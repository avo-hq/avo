# require 'rails/generators/base'

class ResourceGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('templates', __dir__)
  # class_option 'get-fields_from_model', type: :boolean, required: false, default: false, desc: 'Inspects the model and generates fields in resource. Defaults to true.'
  # class argument
  argument :generate_fields, default: false, required: false

  namespace 'avo:resource'

  # class_option :fields, type: :hash, reguired: false, desc: 'Fields that map to Avo field types.'
  # class_option :generate_model, type: :boolean, reguired: false, default: true, desc: 'Setting for running r generate model. Defaults to true.'

  def create_resource_file
    # puts 'COLUMN NAMES:'
    # begin
    #   puts singular_name.classify.constantize.column_names
    #   @modelFields = singular_name.classify.constantize.column_names
    #   singular_name.classify.constantize.column_names.each {|k,v| puts "#{k} => #{v.type}"}
    # rescue NameError => e
    #   puts 'Name error occurs. There is no model with ' + singular_name.classify + '.'
    # rescue => e
    #   puts 'Other error occured.'
    # end
    # puts 'COLUMN HASH:'
    # puts User.attributes

    @fields = generate_fields ? resource_params : {}
    template 'resource.rb', "app/avo/resources/#{singular_name}.rb"
  end

  # def retrieve_model_fields

  # end

  # def generate_model
  #   generate 'model', model_params if generate_model_option
  # end

  # def generate_model_option
  #   options['generate_model']
  # end

  # def fields_option
  #   options['fields']
  # end

  private
    def resource_params
      model = singular_name.classify.constantize
      columnTypeHash = {}
      begin
        # puts singular_name.classify.constantize.columns_hash
        model.columns_hash.each { |k, v| columnTypeHash[k] = v.type }
        puts model.columns_hash
        puts columnTypeHash
      rescue NameError => e
        puts 'Name error occurs. There is no ' + singular_name.classify + ' model.'
      rescue => e
        puts 'Other error occured.'
      end

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

      result = {}
      if !columnTypeHash.empty?
        columnTypeHash.each do |fieldname, fieldtype|
          if name_mappings[fieldname]
            result[fieldname] = name_mappings[fieldname]
          elsif field_mappings[fieldtype]
            result[fieldname] = field_mappings[fieldtype]
          else
            result[fieldname] = 'text'
          end
        end
      end
      result
    end

  # def model_params
  #   result = singular_name + ' '
  #   if fields_option
  #     fields_option.each do |key, value|
  #       result = result + key.to_s + ':' + value.to_s + ' '
  #     end
  #   end
  #   result
  # end
end
