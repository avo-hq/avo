source 'https://rubygems.org'
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

# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
gem 'webpacker', '~> 4.0'

# SVGs
gem 'inline_svg'

gem 'countries'

# Authorization
gem "pundit"

# These are the dummy app's dependencies
group :development, :test do
  # Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
  gem 'rails', '~> 6.0.2', '>= 6.0.2.2'
  # Use postgresql as the database for Active Record
  gem 'pg', '>= 0.18', '< 2.0'
  # Use Puma as the app server
  gem 'puma', '~> 4.3.5'
  # Use SCSS for stylesheets
  gem 'sass-rails', '>= 6'
  # Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
  # gem 'turbolinks', '~> 5'
  # Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
  gem 'jbuilder', '~> 2.7'
  # Use Redis adapter to run Action Cable in production
  # gem 'redis', '~> 4.0'
  # Use Active Model has_secure_password
  # gem 'bcrypt', '~> 3.1.7'

  # Use Active Storage variant
  # gem 'image_processing', '~> 1.2'

  # Reduces boot times through caching; required in config/boot.rb
  gem 'bootsnap', '>= 1.4.2', require: false
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'dotenv-rails'
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'

  gem 'factory_bot_rails'
  gem 'faker'

  # Windows does not include zoneinfo files, so bundle the tzinfo-data gem
  gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

  gem 'devise'
  gem 'database_cleaner'

  gem 'ruby-debug-ide', require: false
  gem 'debase'
end

group :development, :test do
  gem 'rspec-rails', '~> 4.0.0'
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '>= 2.15'
  gem 'selenium-webdriver'
  # Easy installation and use of web drivers to run system tests with browsers
  gem 'webdrivers'
  gem 'fuubar'
  gem 'rubocop'
  gem 'simplecov', require: false
  gem 'simplecov-cobertura'

  # Release helper
  gem 'bump', require: false
  gem 'gem-release', require: false
end

gem 'zeitwerk', '~> 2.3'

# Pagination
gem 'kaminari'
