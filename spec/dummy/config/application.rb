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
# A theme shipped as a gem, loaded by path so the engine discovery path is
# exercised without adding a Gemfile entry (see vendor/avo-harbor_theme).
require_relative "../vendor/avo-harbor_theme/lib/avo/harbor_theme"

# Tell spring where the new dummy ap is located
Spring.application_root = "." if defined?(Spring)

module Avo3Dummy
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    # We're going to load the defaults from the env because we're using appraisal and differently versioned gems.
    config.load_defaults ENV["RAILS_VERSION"] || 8.0

    # Keep the trix field on Trix; Lexxy is used only via `as: :lexxy`.
    # Lexxy requires Rails >= 8.0.2, so it's absent from the Rails 7.1 appraisals.
    config.lexxy.override_action_text_defaults = false if defined?(Lexxy)

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
    config.i18n.raise_on_missing_translations = true
    # ---

    config.action_view.form_with_generates_remote_forms = false

    # Rails.autoloaders.log!
  end
end
