$:.push File.expand_path('lib', __dir__)

# Maintain your gem's version:
require 'avo/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name        = 'avo'
  spec.version     = Avo::VERSION
  spec.authors     = ['Adrian Marin', 'Mihai Marin']
  spec.email       = ['adrian@avohq.io']
  spec.homepage    = 'https://avohq.io'
  spec.summary     = 'Configuration-based, no-maintenance, extendable Ruby on Rails admin.'
  spec.description = 'Avo is a beautiful next-generation framework that empowers you, the developer, to create fantastic admin panels for your Ruby on Rails apps with the flexibility to fit your needs as you grow.'
  spec.license     = 'Commercial'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['bug_tracker_uri'] = 'https://github.com/avo-hq/avo/issues'
    spec.metadata['changelog_uri'] = 'https://avohq.io/releases'
    spec.metadata['documentation_uri'] = 'https://docs.avohq.io'
    spec.metadata['homepage_uri'] = 'https://avohq.io'
    spec.metadata['source_code_uri'] = 'https://github.com/avo-hq/avo'
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end

  spec.post_install_message = "Thank you for using Avo! Docs are available at https://docs.avohq.io"

  spec.files = Dir['{bin,app,config,db,lib,public}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md', 'avo.gemspec', 'Gemfile', 'Gemfile.lock']
    .reject { |file| file.start_with? 'app/frontend' }

  spec.add_dependency 'rails', '>= 6.0'
  spec.add_dependency 'kaminari'
  spec.add_dependency 'zeitwerk'
  spec.add_dependency 'inline_svg'
  spec.add_dependency 'webpacker'
  spec.add_dependency 'countries'
end
