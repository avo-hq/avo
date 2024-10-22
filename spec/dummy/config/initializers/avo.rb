Avo.configure do |config|
  ## == Base configs ==
  config.root_path = "/admin"
  config.app_name = -> { "Avocadelicious #{params[:app_name_suffix]}" }
  config.home_path = -> { "/admin/resources/projects" }
  config.home_path = -> { avo.resources_projects_path }
  # config.mount_avo_engines = false
  # config.default_url_options = [:tenant_id]
  # Use this to test root_path_without_url helper
  # Also enable in config.ru & application.rb
  # ---
  # config.prefix_path = "/development/internal-api"
  # ---

  ## == Licensing ==
  config.license_key = ENV["AVO_LICENSE_KEY"]

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
  config.implicit_authorization = true

  ## == Customization ==
  config.id_links_to_resource = true
  config.full_width_container = false
  config.buttons_on_form_footers = false
  # config.resource_controls_placement = ENV["AVO_RESOURCE_CONTROLS_PLACEMENT"]&.to_sym || :right
  config.resource_default_view = :show
  config.search_debounce = 300
  # config.field_wrapper_layout = :stacked
  config.cache_resource_filters = false
  config.click_row_to_view_record = true

  config.turbo = {
    instant_click: true
  }

  ## == Branding ==
  config.branding = {
    colors: {
      # background: "#FFFCF9", # basecamp
      # background: "#F6F6F7", # original
      # background: "#FBF7F0", # hotwire
      # background: "248 246 242", # cookpad
      # BLUE
      100 => "#CEE7F8",
      400 => "#399EE5",
      500 => "#0886DE",
      600 => "#066BB2",
      # # ORANGE
      # 100 => "#FFECCC",
      # 400 => "#FFB435",
      # 500 => "#FFA102",
      # 600 => "#CC8102",
    },
    # chart_colors: ['#FFB435', "#FFA102", "#CC8102", '#FFB435', "#FFA102", "#CC8102"],
    logo: "/avo-assets/logo.png",
    logomark: "/avo-assets/logomark.png",
    # placeholder: "/avo-assets/placeholder.svg",
  }

  # Uncomment to test out manual resource loading.
  # config.resources = [
  #   "Avo::Resources::User",
  #   "Avo::Resources::Fish"
  # ]

  config.alert_dismiss_time = 5000
  config.search_results_count = 8

  ## == Menus ==
  if Rails.env.test?
    config.main_menu = -> do
      link "Avo", "https://avohq.io"
    end
  end
  # end
  # config.profile_menu = -> do
  #   link "Profile", path: "/profile", icon: "heroicons/outline/user-circle"
  #   # link_to "Sign out", path: main_app.destroy_user_session_path, icon: "user-circle", method: :post, params: {hehe: :hoho}
  # end

  # config.pagination = -> do
  #   {
  #     type: :countless
  #   }
  # end
end

if defined?(Avo::DynamicFilters)
  Avo::DynamicFilters.configure do |config|
    config.button_label = "Advanced filters"
    config.always_expanded = true
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
