Avo.configure do |config|
  ## == Base configs ==
  config.root_path = "/admin"
  config.app_name = -> { "Avocadelicious #{params[:app_name_suffix]}" }
  config.home_path = -> { avo.resources_projects_path }
  # config.default_url_options = [:tenant_id]
  # Use this to test root_path_without_url helper
  # Also enable in config.ru & application.rb
  # ---
  # config.prefix_path = "/development/internal-api"
  # ---

  ## == Licensing ==
  config.license_key = ENV["AVO_LICENSE_KEY"]
  config.exclude_from_status = ["license_key"]

  ## == App context ==
  config.current_user_method = :current_user
  # config.is_admin_method = :is_admin?
  # config.is_developer_method = :is_developer?
  config.model_resource_mapping = {
    User: "User"
  }
  config.set_context do
    {
      foo: "bar",
      user: current_user,
      params: request.params
    }
  end
  config.locale = :en
  # config.raise_error_on_missing_policy = true
  # config.authorization_client = "Avo::Services::AuthorizationClients::ExtraPunditClient"
  # Shouldn't impact on community only if custom authorization service was configured.
  config.explicit_authorization = true

  ## == Customization ==
  config.id_links_to_resource = true
  # config.container_width = :small
  config.use_stacked_fields = false
  config.buttons_on_form_footers = false
  config.resource_default_view = :show
  config.search_debounce = 300
  # config.field_wrapper_layout = :stacked
  config.click_row_to_view_record = true

  config.turbo = {
    instant_click: true
  }

  # config.resource_row_controls_config = {
  #   placement: :right,
  #   float: true,
  #   show_on_hover: true
  # }

  config.sidebar_toggle_visible = true

  # config.hotkeys = {
  #   enabled: true,
  #   # show_key_badges: true
  # }

  ## == Branding ==
  config.branding = {
    logo: "avo/logo.png",
    logomark: "avo/logomark.png",
    mode: :static,
    mode: :dynamic,
    scheme: :auto,
    neutral: :olive,
    accent: :blue
  }

  # on static mode:
  #   - if the scheme is set, we force the scheme and not show the scheme switcher
  #   - if the scheme is not set, we show the scheme switcher and default to auto. the user may choos eit and we save it in the cookies
  #   - if the neutral is set, we force the neutral and not show the neutral switcher
  #   - if the accent is set, we force the accent and not show the accent switcher
  #   - if neutral and accent aren't set, we show the neutral and accent switchers and default to neutral and blue. the user may choose either and we save it in the cookies
  # on dynamic mode:
  #   - we show the scheme switcher
  #   - we store the scheme in the database
  #   - we store the neutral and accent in the database
  #   - we store the mode in the database
  #   - we store the logo in the database
  #   - we store the logomark in the database
  #   - we store the favicon in the database

  # Uncomment to test out manual resource loading.
  # config.resources = [
  #   "Avo::Resources::User",
  #   "Avo::Resources::Fish"
  # ]

  # https://linear.app/avo-hq/issue/AVO-630/add-support-for-ruby-340-and-remove-ruby-314-from-test-matrix
  # Not sure why yet but this is needed to make the test pass
  # ./spec/system/avo/alert_backtrace_spec.rb:21 will not show the alert if the time is 5000
  # only with version rails 8.0.2 and ruby 3.4.5
  # and also only on test environment, in dev it works fine
  config.alert_dismiss_time = Rails.env.test? ? 10000 : 5000
  config.search_results_count = 8
  config.associations_lookup_list_limit = 1000

  ## == Menus ==
  if Rails.env.test?
    config.main_menu = -> do
      link "Avo", "https://avohq.io"
    end
  end
  # end
  # config.profile_menu = -> do
  #   link "Profile", path: "/profile", icon: "tabler/outline/user-circle"
  #   # link_to "Sign out", path: main_app.destroy_user_session_path, icon: "user-circle", method: :post, params: {hehe: :hoho}
  # end

  # config.pagination = -> do
  #   {
  #     type: :countless
  #   }
  # end

  config.column_names_mapping = {
    custom_css: {field: "code"}
  }
end

if defined?(Avo::DynamicFilters)
  Avo::DynamicFilters.configure do |config|
    config.button_label = "Advanced filters"
    config.always_expanded = true
  end
end

if defined?(Avo::MediaLibrary)
  Avo::MediaLibrary.configure do |config|
    config.visible = -> { Avo::Current.user.is_developer? }
    config.enabled = true
  end
end

Rails.configuration.to_prepare do
  Avo::Fields::BaseField.include ActionView::Helpers::UrlHelper
  Avo::Fields::BaseField.include ActionView::Context
  Avo::ApplicationController.include ApplicationControllerExtensions
  Avo::ApplicationController.helper Rails.application.helpers
end

ActiveSupport.on_load(:avo_boot) do
  Avo.plugin_manager.register_field :color_pickerrr, Avo::Fields::ColorPickerField
end
