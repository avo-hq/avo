class Generators::PartialsGenerator < ::Rails::Generators::Base
  source_root File.expand_path('templates', __dir__)
  namespace 'avo:partials'

  def generate
    directory 'partials', Rails.root.join('app', 'views', 'vendor', 'avo', 'partials')
  end
end
