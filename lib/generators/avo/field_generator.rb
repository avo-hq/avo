class FieldGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('templates/field', __dir__)

  # namespace 'avo:field'
  # desc 'Create stubs for a new field.'
  # class_option :name, type: :string

  # def create_files
  #   template "filters/#{type}_filter.rb", "app/services/avocado/filters/#{singular_name}.rb"
  # end
end
