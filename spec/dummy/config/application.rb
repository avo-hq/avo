require_relative "boot"

# require "rails/all"

require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_view/railtie"
require "action_mailer/railtie"
require "action_text/engine"
# require "active_job/railtie"
# require "action_cable/engine"
# require "action_mailbox/engine"
# require "rails/test_unit/railtie"

Bundler.require(*Rails.groups)

# Tell spring where the new dummy ap is located
Spring.application_root = "."

module AvoDummy
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    # We're going to load the defaults from the env because we're using appraisal and differently versioned gems.
    config.load_defaults ENV["RAILS_VERSION"] || 6.1

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # Use this to test root_path_without_url helper
    # Also enable in config.ru & avo.rb (prefix_path)
    # ---
    # config.relative_url_root = "/development/internal-api"
    # ---

    # Use this to test the locale configuration
    # ---
    # config.i18n.available_locales = [:fr, :en, :ro]
    # config.i18n.default_locale = :fr
    # ---

    config.action_view.form_with_generates_remote_forms = false
  end
end
