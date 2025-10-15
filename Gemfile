source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Declare your gem's dependencies in avo.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec

gem "avo-loaders", path: "../avo-loaders"

# =============================================================================
# RAILS & CORE DEPENDENCIES
# =============================================================================
gem "rails", ">= 8.0.0"
# gem "rails", github: "rails/rails", branch: "main"

# ActiveStorage for file uploads
gem "activestorage", ">= 8.0.0"

# Asset pipeline
gem "jsbundling-rails"
gem "cssbundling-rails"
gem "propshaft"

# =============================================================================
# DATABASE & ORM
# =============================================================================
gem "pg", ">= 0.18", "< 2.0"

# =============================================================================
# SERVER & DEPLOYMENT
# =============================================================================
gem "puma", "~> 6.4"
gem "bootsnap", ">= 1.4.2", require: false
gem "redis", "~> 5.0"

# =============================================================================
# AUTHENTICATION & AUTHORIZATION
# =============================================================================
gem "devise"

# =============================================================================
# SEARCH & FILTERING
# =============================================================================
gem "ransack", ">= 4.2.0"

# =============================================================================
# UI & FRONTEND
# =============================================================================
gem "active_link_to"
gem "meta-tags"
gem "friendly_id", "~> 5.5.1"

# =============================================================================
# DATA & ANALYTICS
# =============================================================================
gem "groupdate"
gem "hightop"
gem "active_median"
gem "chartkick"
gem "mapkick-rb", "~> 0.1.4"
gem "mapkick-static"

# =============================================================================
# UTILITIES & HELPERS
# =============================================================================
gem "zeitwerk"
gem "iso"
gem "addressable"
gem "acts_as_list"
gem "acts-as-taggable-on", "~> 12.0"
gem "bundler-integrity", "~> 1.0"
gem "countries"
gem "image_processing", "~> 1.12"
gem "prefixed_ids"
gem "hashid-rails", "~> 1.4", ">= 1.4.1"
gem "money-rails", "~> 1.12"
gem "pagy", "> 8"
gem "csv"
gem "view_component", "4.0.0"

# =============================================================================
# AWS & CLOUD SERVICES
# =============================================================================
gem "aws-sdk-s3", require: false
gem "net-smtp", require: false

# =============================================================================
# AVO EXTENSIONS
# =============================================================================
gem "avo-money_field"
gem "avo-record_link_field"
gem "pluggy", path: "./pluggy"

# =============================================================================
# DEVELOPMENT
# =============================================================================
group :development do
  # Code quality & linting
  gem "standard", require: false
  gem "rubocop", require: false
  gem "rubocop-shopify", require: false
  gem "rubycritic", require: false

  # Release helpers
  gem "bump", require: false
  gem "gem-release", require: false

  # Documentation & annotations
  gem "annotate"
  gem "ripper-tags", require: false

  # Development tools
  gem "htmlbeautifier"
  gem "hotwire-livereload", "~> 1.3.0"
  gem "actual_db_schema"

  # Component documentation & preview
  gem "lookbook", ">= 2.3.8"

  # Performance profiling
  gem "derailed_benchmarks", "~> 2.1", ">= 2.1.2"
  gem "ruby-statistics", "< 4"  # Keep version locked until derailed_benchmarks PR gets merged

  # Development console & debugging
  gem "web-console", ">= 3.3.0"
  # Required by lookbook for livereload
  gem "listen", ">= 3.5.1"
  gem "actioncable"
  gem "debug", platforms: [:mri, :mingw, :x64_mingw]

  # Uncomment for performance profiling
  # gem "rack-mini-profiler"
  # gem "memory_profiler"
  # gem "stackprof"
  # gem "ruby-prof"
  # gem "pry-rails"
end

# =============================================================================
# TEST
# =============================================================================
group :test do
  # RSpec & testing framework
  gem "rspec-rails", "~> 6.0", ">= 6.0.3"
  gem "rspec-retry", "~> 0.6.2"
  gem "rails-controller-testing"

  # Browser testing
  gem "capybara"
  gem "cuprite"

  # Test utilities
  gem "fuubar"
  gem "webmock"
  gem "launchy", require: false
  gem "spring"
  gem "spring-commands-rspec"

  # Coverage reporting
  gem "simplecov", require: false
  gem "simplecov-cobertura"
  gem "simplecov-lcov"

  # Performance testing
  gem "test-prof"
  gem "database_cleaner-active_record"
end

# =============================================================================
# DEVELOPMENT & TEST
# =============================================================================
group :development, :test do
  # Debugging & console
  gem "amazing_print"
  gem "dotenv-rails"

  # Test data & factories
  gem "faker", require: false
  gem "factory_bot_rails"

  # Code quality & linting
  gem "i18n-tasks", "~> 1.0.12"
  gem "erb-formatter", require: false
  gem "erb_lint", require: false

  # Language server & IDE support
  gem "solargraph", require: false
  gem "solargraph-rails", require: false

  # AI & external services
  gem "ruby-openai"

  # Build & dependency management
  gem "appraisal", require: false
end

# =============================================================================
# PLATFORM SPECIFIC
# =============================================================================
# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: [:mingw, :mswin, :x64_mingw, :jruby]
