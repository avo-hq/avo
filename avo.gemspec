# $:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require_relative "lib/avo/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name = "avo"
  spec.version = Avo::VERSION
  spec.authors = ["Adrian Marin", "Mihai Marin", "Paul Bob"]
  spec.email = ["hi@avohq.io"]
  spec.homepage = "https://avohq.io"
  spec.summary = "Admin panel framework and Content Management System for Ruby on Rails."
  spec.description = "Avo is a very custom Content Management System for Ruby on Rails that saves engineers and teams months of development time by building user interfaces and logic using configuration rather than traditional coding; When configuration is not enough, you can fallback to familiar Ruby on Rails code."
  spec.license = "LGPL-3.0"
  spec.licenses = ["LGPL-3.0", "Commercial"]

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

  spec.required_ruby_version = ">= 3.2.0"
  spec.post_install_message = "Thank you for using Avo 💪  Docs are available at https://docs.avohq.io"

  # NOTE: `public/` is rejected below — Avo 4 ships precompiled assets from
  # `app/assets/builds`, and a stale `public/avo-assets` dir was what bloated some builds.
  #
  # `app/assets/builds` is gitignored and `Dir` does not read .gitignore, so whatever a
  # releaser's working copy happens to hold there is packaged. Only `app/assets/builds/avo/`
  # is ours — every build script writes there. 4.2.2 shipped `avo.base.js`, `avo.custom.js`,
  # `late-registration.js` and `avo.base.css` from the top level: output of the build scripts
  # as they stood before #3971 moved them into `avo/`, left on one machine since July 2025.
  # It cost 22MB, and the stray `avo.custom.js` took over that Sprockets logical path in any
  # host app that had an `avo.custom.js` of its own — silently replacing the host's file.
  spec.files = Dir["{bin,app,config,db,lib,public}/**/*", "Rakefile", "README.md", "NOTICE" "avo.gemspec", "Gemfile", "Gemfile.lock", "tailwind.preset.js", "tailwind.custom.js", "safelist.txt"]
    .reject { |f| f.start_with?("public/") }
    .reject { |f| f.start_with?("app/assets/builds/") && !f.start_with?("app/assets/builds/avo/") }

  spec.add_dependency "activerecord", ">= 6.1"
  spec.add_dependency "activesupport", ">= 6.1"
  spec.add_dependency "actionview", ">= 6.1"
  spec.add_dependency "pagy", ">= 43.0"
  spec.add_dependency "zeitwerk", ">= 2.6.12"
  spec.add_dependency "active_link_to"
  spec.add_dependency "view_component", ">= 3.7.0"
  spec.add_dependency "turbo-rails", ">= 2.0.0"
  spec.add_dependency "turbo_power", ">= 0.6.0"
  spec.add_dependency "addressable"
  spec.add_dependency "meta-tags"
  spec.add_dependency "docile"
  spec.add_dependency "prop_initializer", ">= 0.3.0"
  spec.add_dependency "avo-icons", ">= 0.1.2"
end
