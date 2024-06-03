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

#
# Dependencies for dummy_app
#
# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
# gem "rails", "~> 7.1.0"
gem "rails", github: "rails/rails", branch: "main"

# Avo file filed requires this gem
# gem "activestorage"
gem "activestorage", github: "rails/rails", branch: "main"

# Use postgresql as the database for Active Record
gem "pg", ">= 0.18", "< 2.0"
# Use Puma as the app server
gem "puma", "~> 6.4"
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem "jbuilder", "~> 2.7"
# Use Redis adapter to run Action Cable in production
gem 'redis', '~> 5.0'
# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'

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
# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: [:mingw, :mswin, :x64_mingw, :jruby]

gem "devise"
#
# END Dependencies for dummy_app
#

group :development do
  gem "standard"

  # Release helper
  gem "bump", require: false
  gem "gem-release", require: false

  gem "annotate"

  # gem 'rack-mini-profiler'
  # gem 'memory_profiler'
  # gem 'stackprof'
  # gem 'ruby-prof'

  # gem 'pry-rails'

  gem "htmlbeautifier"

  gem "hotwire-livereload", "~> 1.3.0"

  gem "rubocop"
  gem "ripper-tags"
  gem "rubocop-shopify", require: false
  gem "rubycritic", require: false
end

group :test do
  gem "rspec-rails", "~> 6.0", ">= 6.0.3"
  gem "rspec-retry", "~> 0.6.2"
  gem "rails-controller-testing"
  gem "capybara"
  gem "cuprite"
  gem "fuubar"
  gem "simplecov", require: false
  gem "simplecov-cobertura"
  gem "simplecov-lcov"
  gem "webmock"
  gem "spring-commands-rspec"
  gem "launchy", require: false

  gem "test-prof"
  gem "database_cleaner-active_record"
end

gem "awesome_print"

group :development, :test do
  gem "faker", require: false
  gem "i18n-tasks", "~> 1.0.12"
  gem "erb-formatter"
  # https://thoughtbot.com/blog/a-standard-way-to-lint-your-views
  gem "erb_lint"
  gem "solargraph"
  gem "solargraph-rails"

  gem "factory_bot_rails"

  gem "appraisal"
end

gem "zeitwerk"

gem "httparty"

gem "iso"

gem "active_link_to"

gem "addressable"

gem 'meta-tags'

# Search
# gem "ransack", "~> 4.1", ">= 4.1.1"

# Temporary use of fork to add Rails 8 support
gem "ransack", github: "avo-hq/ransack", branch: "fix/rails-8/delegate-alias-tracker-to-relation"

gem 'friendly_id', '~> 5.5.1'

gem 'aws-sdk-s3', require: false

gem 'net-smtp', require: false

# Dashboard charts
gem "groupdate"
gem "hightop"
gem "active_median"

gem 'acts_as_list'

# gem 'acts-as-taggable-on', '~> 10.0'
gem "acts-as-taggable-on", github: "avo-hq/acts-as-taggable-on"

gem "bundler-integrity", "~> 1.0"

# Avo country field requires this gem
gem "countries"

# Avo dashbaords requires this gem
gem "chartkick"

# Required by Avo
gem "sprockets-rails"

# Avo file field requires this gem
# Use Active Storage variant
gem "image_processing", "~> 1.12"

# source "https://rubygems.pkg.github.com/avo-hq" do
#   gem "avo-dynamic_filters"
# end
gem "prefixed_ids"

gem "mapkick-rb", "~> 0.1.4"

gem "pluggy", path: "./pluggy"

gem "hashid-rails", "~> 1.4", ">= 1.4.1"

# Avo money field
# gem "avo-money_field", path: "./../avo-money_field"
gem "money-rails", "~> 1.12"
gem "avo-money_field"

# Avo record_link field
# gem "avo-record_link_field", path: "./../avo-record_link_field"
gem "avo-record_link_field"

# gem "pagy", "< 8.0.0"
gem "pagy", "> 8"
