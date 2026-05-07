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
  config.authorization_client = nil
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
    logo_dark: "avo/logo-dark.png",
    logomark: "avo/logomark.png",
    logomark_dark: "avo/logomark-dark.png",
    favicon: "avo/favicon.ico",
    favicon_dark: "avo/favicon-dark.ico",
    # scheme: :dark, # :auto, :light, :dark
    # neutral: :olive, # :brand, :slate, :stone or any other tailwind color name
    # accent: :blue, # :neutral, :red, :orange, or any other tailwind color name
    # lock: [:neutral], # [:scheme, :neutral, :accent]
    # neutrals: %w[brand mist olive],
    # accents: %w[brand red orange pink rose],
    # Override the brand neutral and accent palettes. Both keys are independent —
    # set one, the other, both, or neither.
    # All 12 shades are required for `neutral_colors`; all three tokens for `accent_colors`.
    # Both `light:` and `dark:` schemes are required for either key.
    # Values are passed through verbatim — any string a CSS custom property
    # accepts works (`oklch(...)`, `#hex`, `rgb(...)`, `hsl(...)`, `var(...)`).
    # Comment this block out to see Avo's defaults instead.
    # neutral_colors: {
    #   light: {
    #     25 => "oklch(98.5% 0.005 60)",
    #     50 => "oklch(97%   0.008 60)",
    #     100 => "oklch(93%   0.012 60)",
    #     200 => "oklch(86%   0.015 60)",
    #     300 => "oklch(76%   0.015 60)",
    #     400 => "oklch(63%   0.014 60)",
    #     500 => "oklch(53%   0.013 60)",
    #     600 => "oklch(48%   0.012 60)",
    #     700 => "oklch(43%   0.011 60)",
    #     800 => "oklch(39%   0.010 60)",
    #     900 => "oklch(28%   0.008 60)",
    #     950 => "oklch(20%   0.005 60)"
    #   },
    #   dark: {
    #     25 => "oklch(98.5% 0.005 60)",
    #     50 => "oklch(97%   0.008 60)",
    #     100 => "oklch(93%   0.012 60)",
    #     200 => "oklch(86%   0.015 60)",
    #     300 => "oklch(76%   0.015 60)",
    #     400 => "oklch(63%   0.014 60)",
    #     500 => "oklch(53%   0.013 60)",
    #     600 => "oklch(48%   0.012 60)",
    #     700 => "oklch(43%   0.011 60)",
    #     800 => "oklch(39%   0.010 60)",
    #     900 => "oklch(28%   0.008 60)",
    #     950 => "oklch(20%   0.005 60)"
    #   }
    # },
    # accent_colors: {
    #   light: {color: "oklch(55% 0.2 280)", content: "oklch(45% 0.2 280)", foreground: "oklch(99% 0 0)"},
    #   dark: {color: "oklch(70% 0.2 280)", content: "oklch(80% 0.15 280)", foreground: "oklch(15% 0.05 280)"}
    # },
    persistence: :database, # :database or :cookie
    load_settings: -> { current_user&.theme_settings&.symbolize_keys || {} },
    save_settings: -> {
      user = current_user
      next unless user

      user.update!(
        theme_settings: user.theme_settings.symbolize_keys.merge(settings.symbolize_keys)
      )
    }
  }

  # `lock:` accepts any subset of [:scheme, :neutral, :accent].
  # - A key in `lock:` hides its switcher and forces the configured value.
  # - Anything not in `lock:` is exposed as a switcher, with the configured value as default.
  # - `persistence:` (`:cookie` | `:database`) controls where unlocked user picks are stored.

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
  # on dynamic mode (:database):
  #   - PATCH /theme_settings sends a partial JSON body (only scheme, neutral, or accent changed).
  #   - merge `settings` in `save_settings`; load the full hash in `load_settings`.

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
