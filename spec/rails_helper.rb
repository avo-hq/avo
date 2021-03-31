# This file is copied to spec/ when you run 'rails generate rspec:install'
require "spec_helper"
ENV["RAILS_ENV"] = "test"

require_relative "dummy/config/environment"
# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
require "rspec/rails"
require "webmock/rspec"

require "test_prof/any_fixture"
require "test_prof/any_fixture/dsl"
# Add additional requires below this line. Rails is not loaded until this point!

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
# Dir[Rails.root.join('spec', 'support', '**', '*.rb')].sort.each { |f| require f }

# Checks for pending migrations and applies them before tests are run.
# If you are not using ActiveRecord, you can remove these lines.
# begin
#   ActiveRecord::Migration.maintain_test_schema!
# rescue ActiveRecord::PendingMigrationError => e
#   puts e.to_s.strip
#   exit 1
# end

Avo::App.boot

# ActiveRecord::Migrator.migrate(File.join(Rails.root, 'db/migrate'))

test_driver = ENV["HEADFULL"] ? :selenium_chrome : :selenium_chrome_headless

require "support/controller_routes"

RSpec.configure do |config|
  config.include TestHelpers::ControllerRoutes, type: :controller
  config.include TestHelpers::DisableAuthentication, type: :system
  config.include TestHelpers::DisableAuthentication, type: :feature
  config.include TestHelpers::DisableHQRequest
  config.include Warden::Test::Helpers

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  # config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  config.before(:each, type: :system) do
    driven_by test_driver
  end

  config.before(:each, type: :system, js: true) do
    driven_by test_driver
  end

  config.before(:example) do
    Rails.cache.clear
  end

  config.around(:example, type: :system) do |example|
    # Stub license request for system tests.
    stub_request(:post, Avo::Licensing::HQ::ENDPOINT).to_return(status: 200, body: {}.to_json, headers: json_headers)
    ENV["RUN_WITH_NULL_LICENSE"] = "1"
    WebMock.disable_net_connect!(allow_localhost: true, allow: "chromedriver.storage.googleapis.com")
    example.run
    WebMock.allow_net_connect!
    WebMock.reset!
    ENV["RUN_WITH_NULL_LICENSE"] = "0"
  end

  # You can uncomment this line to turn off ActiveRecord support entirely.
  # config.use_active_record = false

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, type: :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")
end

require "support/helpers"
require "support/factory_bot"
require "support/database_cleaner"
require "support/wait_for_loaded"
require "support/js_error_detector"
require "support/devise"
require "support/shared_contexts"
