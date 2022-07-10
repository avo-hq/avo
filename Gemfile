source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Declare your gem's dependencies in avo.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec

# Declare any dependencies that are still in development here instead of in
# your gemspec. These might include edge Rails or gems from your path or
# Git. Remember to move these dependencies to your gemspec before releasing
# your gem to rubygems.org.

# To use a debugger
# gem 'byebug', group: [:development, :test]

gem 'jsbundling-rails'
gem 'cssbundling-rails'

gem "countries"

# Authorization
gem "pundit"

#
# Dependencies for dummy_app
#
# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem "rails", "~> 6.1.0"
# Use postgresql as the database for Active Record
gem "pg", ">= 0.18", "< 2.0"
# Use Puma as the app server
gem "puma", "~> 5.6.4"
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem "jbuilder", "~> 2.7"
# Use Redis adapter to run Action Cable in production
gem 'redis', '~> 4.0'
# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Active Storage variant
gem "image_processing", "~> 1.12"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", ">= 1.4.2", require: false
# Call 'byebug' anywhere in the code to stop execution and get a debugger console
gem "byebug", platforms: [:mri, :mingw, :x64_mingw]
gem "dotenv-rails"
# Access an interactive console on exception pages or by calling 'console' anywhere in the code.
gem "web-console", ">= 3.3.0"
gem "listen", ">= 3.5.1"
# Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
gem "spring"

gem "factory_bot_rails"
# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: [:mingw, :mswin, :x64_mingw, :jruby]

gem "devise"
gem "database_cleaner"

gem "ruby-debug-ide", require: false
#
# END Dependencies for dummy_app
#

group :development do
  gem "standard"

  # Release helper
  gem "bump", require: false
  gem "gem-release", require: false

  gem 'annotate'

  # gem 'rack-mini-profiler'
  # gem 'memory_profiler'
  # gem 'stackprof'
  # gem 'ruby-prof'

  # gem 'pry-rails'

  gem 'htmlbeautifier'

  gem "hotwire-livereload", "~> 1.1"
end

group :development, :test do
  gem "awesome_print"
  gem "faker", require: false
end

group :test do
  gem "rspec-rails", "~> 4.0.0"
  gem "rails-controller-testing"
  # Adds support for Capybara system testing and selenium driver
  gem "capybara", "3.36"
  gem "selenium-webdriver"
  # Easy installation and use of web drivers to run system tests with browsers
  gem "webdrivers"
  gem "fuubar"
  gem "simplecov", require: false
  gem "simplecov-cobertura"
  gem "webmock"
  gem "spring-commands-rspec"
  gem "launchy", require: false

  gem "test-prof"
end

gem "rubocop"
gem "rubocop-shopify", require: false

gem "zeitwerk", "~> 2.3"

gem "httparty"

gem "iso"

gem "hotwire-rails"

gem "active_link_to"

gem "view_component"

gem "addressable"

gem "appraisal"

gem 'meta-tags'

gem 'breadcrumbs_on_rails'

gem 'manifester'

# Search
gem 'ransack'

gem 'friendly_id', '~> 5.4.0'

gem 'aws-sdk-s3', require: false

gem 'net-smtp', require: false

# Dashboard charts
gem "groupdate"
gem "hightop"
gem "active_median"

gem 'acts_as_list'

gem 'acts-as-taggable-on', '~> 9.0'

gem "bundler-integrity", "~> 1.0"

gem 'erb-formatter'
