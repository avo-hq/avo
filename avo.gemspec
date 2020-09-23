$:.push File.expand_path('lib', __dir__)

# Maintain your gem's version:
require 'avo/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name        = 'avo'
  spec.version     = Avo::VERSION
  spec.authors     = ['Adrian Marin']
  spec.email       = ['adrian@adrianthedev.com']
  spec.homepage    = 'https://adrianthedev.com'
  spec.summary     = 'Make it easy.'
  spec.description = 'Easy admin.'
  spec.license     = 'MIT'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'https://rubygems.pkg.github.com/avo-hq'
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end

  spec.files = Dir['{bin,app,config,db,lib,public}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md', 'avo.gemspec', 'Gemfile', 'Gemfile.lock'].reject { |file| file.start_with? 'app/frontend' }

  spec.add_dependency 'rails', '~> 6.0.2', '>= 6.0.2.1'
  spec.add_dependency 'kaminari'
  spec.add_dependency 'zeitwerk'
  spec.add_dependency 'inline_svg'
  spec.add_dependency 'webpacker'
end
