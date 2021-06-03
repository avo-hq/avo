require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups)

# Tell spring where the new dummy ap is located
Spring.application_root = "."

module Dummy
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    # We're going to load the defaults from the env because we're using appraisal and differently versioned gems.
    config.load_defaults ENV["RAILS_VERSION"] || 6.1

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    config.action_view.form_with_generates_remote_forms = false
  end
end
