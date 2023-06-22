Avo.configure do |config|
  ## == Base configs ==
  config.root_path = "/admin"
  config.app_name = -> { "Avocadelicious #{params[:app_name_suffix]}" }
  config.home_path = -> { avo.dashboard_path(:dashy) }
  config.set_initial_breadcrumbs do
    add_breadcrumb "Dashboard", "/admin/dashboards/dashy"
  end
  # Use this to test root_path_without_url helper
  # Also enable in config.ru & application.rb
  # ---
  # config.prefix_path = "/development/internal-api"
  # ---

  ## == Licensing ==
  config.license = "pro"
  config.license_key = ENV["AVO_LICENSE_KEY"]

  ## == App context ==
  config.current_user_method = :current_user
  config.model_resource_mapping = {
    User: "UserResource"
  }
  config.set_context do
    {
      foo: "bar",
      user: current_user,
      params: request.params
    }
  end
  config.authorization_methods = {
    search: "avo_search?" # override this method
  }
  # config.raise_error_on_missing_policy = true
  # config.authorization_client = "Avo::Services::AuthorizationClients::ExtraPunditClient"

  ## == Customization ==
  config.id_links_to_resource = true
  config.full_width_container = false
  config.buttons_on_form_footers = false
  # config.resource_controls_placement = ENV["AVO_RESOURCE_CONTROLS_PLACEMENT"]&.to_sym || :right
  config.resource_default_view = :show
  config.search_debounce = 300
  # config.field_wrapper_layout = :stacked

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
      600 => "#066BB2"
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
  #   "UserResource",
  #   "FishResource",
  # ]

  ## == Menus ==
  config.main_menu = -> do
    section I18n.t("avo.dashboards"), icon: "dummy-adjustments.svg" do
      dashboard :dashy, visible: -> { true }, icon: "bolt"
      dashboard "Sales", visible: -> { true }

      group "All dashboards", visible: false, collapsable: true do
        all_dashboards
      end
    end

    section "Resources", icon: "heroicons/solid/building-storefront", collapsable: true, collapsed: false do
      group "Company", collapsable: true do
        resource :projects
        resource :team, visible: -> {
          authorize current_user, Team, "index?", raise_exception: false
        }
        resource :team_membership, visible: -> {
          authorize current_user, TeamMembership, "index?", raise_exception: false

          false
        }
        resource :reviews
      end

      group "People", collapsable: true do
        resource "UserResource", visible: -> do
          authorize current_user, User, "index?", raise_exception: false
        end
        resource :people
        resource :spouses
      end

      group "Education", collapsable: true do
        resource :course
        resource :course_link
      end

      group "Blog", collapsable: true do
        # resource :z_posts
        resource :posts
        resource :comments, icon: "chat-bubble-bottom-center-text"
        resource :photo_comments, visible: -> do
          authorize current_user, Comment, "index?", policy_class: PhotoCommentPolicy, raise_exception: false
        end
      end

      section "Store", icon: "currency-dollar" do
        resource :products
      end

      group "Other", collapsable: true, collapsed: true do
        resource :fish, label: "Fishies"
      end
    end

    section "Geography", icon: "heroicons/outline/globe", collapsable: true, collapsed: true do
      resource :city
    end

    section "Tools", icon: "heroicons/outline/finger-print", collapsable: true, collapsed: true do
      all_tools
    end

    group do
      link "Avo", "https://avohq.io"
      link_to "Google", "https://google.com", target: :_blank
    end
  end
  config.profile_menu = -> do
    link "Profile", path: "/profile", icon: "user-circle"
    # link_to "Sign out", path: main_app.destroy_user_session_path, icon: "user-circle", method: :post, params: {hehe: :hoho}
  end
end

Rails.configuration.to_prepare do
  Avo::Fields::BaseField.include FieldExtensions
  Avo::ApplicationController.include ApplicationControllerExtensions
end
