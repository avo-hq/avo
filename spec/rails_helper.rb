# This file is copied to spec/ when you run 'rails generate rspec:install'
require "spec_helper"
require "fileutils"

ENV["RAILS_ENV"] = "test"

require_relative "dummy/config/environment"
# Prevent database truncation if the environment is production
if Rails.env.production?
  abort("The Rails environment is running in production mode!")
end

require "rspec/rails"
require "webmock/rspec"
require "capybara/cuprite"

require "test_prof/any_fixture"
require "test_prof/any_fixture/dsl"

ENV["TZ"] ||= "UTC"

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

Avo.boot

# ActiveRecord::Migrator.migrate(File.join(Rails.root, 'db/migrate'))

# Ensure that there are no unpermitted_parameters logs
ActionController::Parameters.action_on_unpermitted_parameters = :raise

require "support/download_helpers"
require "support/request_helpers"

# Needed setup for headless download
def headless_download_setup(driver)
  bridge = driver.browser.send(:bridge)

  path = "/session/:session_id/chromium/send_command"
  path[":session_id"] = bridge.session_id

  bridge.http.call(:post, path, cmd: "Page.setDownloadBehavior",
    params: {
      behavior: "allow",
      downloadPath: DownloadHelpers::PATH.to_s
    })

  driver
end

# Fix this. Rails 6.1 with ruby 3.3.0 need this to pass actions test. Uses this path as download path
# Issue: screenshots also go to same path
Capybara.save_path = if Rails::VERSION::MAJOR == 6 && Rails::VERSION::MINOR == 1
  DownloadHelpers::PATH
else
  "tmp/screenshots"
end

Capybara.default_max_wait_time = 5

require "support/controller_routes"
require "support/avo_helpers"
require "support/filter_helpers"

RSpec.configure do |config|
  config.include TestHelpers::ControllerRoutes, type: :controller
  config.include Requests::JsonHelpers, type: :controller
  config.include TestHelpers::DisableAuthentication, type: :system
  config.include TestHelpers::DisableAuthentication, type: :feature
  config.include TestHelpers::DisableHQRequest
  config.include TestHelpers::AvoHelpers, type: :feature
  config.include TestHelpers::AvoHelpers, type: :system
  config.include TestHelpers::FilterHelpers, type: :feature
  config.include TestHelpers::FilterHelpers, type: :system
  config.include Warden::Test::Helpers
  config.include DownloadHelpers
  config.include ViewComponent::TestHelpers, type: :component
  config.include Avo::TestHelpers

  # Include Avo::PrefixedTestHelpers if you want to use the avo_ prefixed helpers
  # config.include Avo::PrefixedTestHelpers

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  # config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true
  config.before(:each) do
    Rails.application.try(:reload_routes_unless_loaded)
  end

  config.before(:each, type: :system) {
    browser_options = {
      save_path: DownloadHelpers::PATH
    }
    if ENV["DOCKER"]
      browser_options["no-sandbox"] = nil
    end

    driven_by(
      :cuprite,
      screen_size: [1400, 1024],
      options: {
        save_path: DownloadHelpers::PATH,
        # js_errors: true, # consider it
        headless: %w[0 false].exclude?(ENV["HEADLESS"]),
        slowmo: ENV["SLOWMO"]&.to_f,
        process_timeout: 15,
        timeout: 10,
        browser_options: browser_options
      }
    )
  }

  config.filter_gems_from_backtrace("capybara", "cuprite", "ferrum")

  config.before(:example) { Rails.cache.clear }

  DownloadHelpers.ensure_directory_exists

  config.after(:example) { clear_downloads }

  config.around(:example, type: :system) do |example|
    # Stub license request for system tests.
    stub_request(:post, Avo::Licensing::HQ::ENDPOINT).to_return(
      status: 200,
      body: {}.to_json,
      headers: json_headers
    )
    ENV["RUN_WITH_NULL_LICENSE"] = "1"

    WebMock.disable_net_connect!(
      net_http_connect_on_start: true,
      allow_localhost: true,
      allow: ["googlechromelabs.github.io", "edgedl.me.gvt1.com"]
    )
    example.run

    # WebMock.allow_net_connect!
    WebMock.allow_net_connect!(net_http_connect_on_start: true)
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

  # https://medium.com/@velciov.vlad/retrying-flaky-tests-fae14de26c1b
  # only retry in CI environment
  config.default_retry_count = ENV["CI"] ? 3 : 0
  config.verbose_retry = true

  # callback to be run between retries
  config.retry_callback = proc do |example|
    # marks this test as flaky so we can identify it even if it
    # passed at later retries
    example.metadata[:flaky] = true
  end
end

require "support/helpers"
require "support/factory_bot"
require "support/database_cleaner"
require "support/js_error_detector"
require "support/devise"
require "support/shared_contexts"
require "support/timezone"

# https://github.com/titusfortner/webdrivers/issues/247
# Webdrivers::Chromedriver.required_version = "114.0.5735.90"
# Webdrivers::Chromedriver.required_version = "116.0.5845.96"
