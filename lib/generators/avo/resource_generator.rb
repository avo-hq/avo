class ResourceGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('templates', __dir__)

  namespace 'avo:resource'

  def create_resource_file
    template 'resource.rb', "app/services/avo/resources/#{singular_name}.rb"
  end
end
