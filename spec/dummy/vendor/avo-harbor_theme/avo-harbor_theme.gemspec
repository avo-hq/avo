require_relative "lib/avo/harbor_theme/version"

Gem::Specification.new do |spec|
  spec.name = "avo-harbor_theme"
  spec.version = Avo::HarborTheme::VERSION
  spec.authors = ["Avo"]
  spec.summary = "Dummy-app fixture: a theme shipped as a gem."
  spec.files = Dir["{app,lib}/**/*", "README.md"]
  spec.add_dependency "avo"
end
