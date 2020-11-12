class FilterGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('templates', __dir__)
  class_option :select, type: :boolean
  class_option :date, type: :boolean

  namespace 'avo:filter'

  def create_resource_file
    type = 'boolean'

    type = 'select' if options[:select]

    type = 'date' if options[:date]

    template "filters/#{type}_filter.rb", "app/services/avo/filters/#{singular_name}.rb"
  end
end
