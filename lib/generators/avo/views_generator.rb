class ViewsGenerator < Rails::Generators::Base
  source_root File.expand_path('templates', __dir__)
  namespace 'avo:views'

  def generate
    directory 'views', Rails.root.join('app', 'views', 'vendor', 'avo', 'partials')
  end
end
