require 'rails/generators/base'

class ResourceGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('templates', __dir__)
  desc 'Creates an Avo resource'
  namespace 'avo:resource'

  class_option :fields, type: :hash, reguired: false, desc: 'Fields that map to Avo field types.'
  class_option :generate_model, type: :boolean, reguired: false, default: true, desc: 'Setting for running r generate model. Defaults to true.'

  def create_resource_file
    @fieldsHash = resource_params
    template 'resource.rb', "app/avo/resources/#{singular_name}.rb"
  end

  def generate_model
    generate 'model', model_params if generate_model_option

  def generate_model_option
    options['generate_model']
  end

  def fields_option
    options['fields']
  end

  def resource_params
    field_mappings = {
      "primary_key" => "id",
      "string" => "text",
      "text" => "textarea",
      "integer" => "number",
      "float" => "number",
      "decimal" => "number",
      "datetime" => "datetime",
      "timestamp" => "datetime",
      "time" => "datetime",
      "date" => "date",
      "binary" => "number",
      "boolean" => "boolean",
      "references" => "text",
    }

    name_mappings = {
      "description" => "textarea",
      "gravatar" => "gravatar",
      "email" => "email",
      "password" => "password",
      "password_confirmation" => "password",
      "stage" => "select",
      "budget" => "currency",
      "money" => "currency",
    }

    result = {}
    if fields_option
      fields_option.each do |fieldname, fieldtype|
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

  def model_params
    result = singular_name + ' '
    if fields_option
      fields_option.each do |key, value|
        result = result + key.to_s + ':' + value.to_s + ' '
      end
    end
    result
  end
end
