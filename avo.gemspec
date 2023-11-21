# $:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require_relative "lib/avo/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name = "avo"
  spec.version = Avo::VERSION
  spec.authors = ["Adrian Marin", "Mihai Marin"]
  spec.email = ["avo@avohq.io"]
  spec.homepage = "https://avohq.io"
  spec.summary = "Configuration-based, no-maintenance, extendable Ruby on Rails admin panel framework."
  spec.description = "Avo abstracts away the common parts of building apps, letting your engineers work on your app's essential components. The result is a full-featured admin panel that works out of the box, ready to give to your end-users."
  spec.license = "Commercial"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["bug_tracker_uri"] = "https://github.com/avo-hq/avo/issues"
    spec.metadata["changelog_uri"] = "https://avohq.io/releases"
    spec.metadata["documentation_uri"] = "https://docs.avohq.io"
    spec.metadata["homepage_uri"] = "https://avohq.io"
    spec.metadata["source_code_uri"] = "https://github.com/avo-hq/avo"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.required_ruby_version = ">= 3.0.0"
  spec.post_install_message = "Thank you for using Avo 💪  Docs are available at https://docs.avohq.io"

  spec.files = Dir["{bin,app,config,db,lib,public}/**/*", "MIT-LICENSE", "Rakefile", "README.md", "avo.gemspec", "Gemfile", "Gemfile.lock", "tailwind.preset.js", "tailwind.custom.js"]
  spec.files.reject! { |file_name| %w[avo.custom.js avo.custom.js.map].any? { |rejected_file| file_name.include? rejected_file } }

  spec.add_dependency "activerecord", ">= 6.1"
  spec.add_dependency "activesupport", ">= 6.1"
  spec.add_dependency "actionview", ">= 6.1"
  spec.add_dependency "pagy"
  spec.add_dependency "zeitwerk", ">= 2.6.12"
  spec.add_dependency "httparty"
  spec.add_dependency "active_link_to"
  spec.add_dependency "view_component", ">= 3.7.0"
  spec.add_dependency "turbo-rails"
  spec.add_dependency "turbo_power", "~> 0.5.0"
  spec.add_dependency "addressable"
  spec.add_dependency "meta-tags"
  spec.add_dependency "dry-initializer"
  spec.add_dependency "docile"
  spec.add_dependency "inline_svg"
end
