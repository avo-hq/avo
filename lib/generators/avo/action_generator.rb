class ActionGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('templates', __dir__)
  namespace 'avo:action'

  def create_resource_file
    template 'action.rb', "app/avo/actions/#{singular_name}.rb"
  end
end
