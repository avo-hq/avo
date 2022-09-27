Avo.configure do |config|
  config.root_path = "/admin"
  config.app_name = "Avocadelicious"
  config.license = "pro"
  config.license_key = ENV["AVO_LICENSE_KEY"]
  config.current_user_method = :current_user
  config.id_links_to_resource = true
  config.full_width_container = true
  config.buttons_on_form_footers = false
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
      # # RED
      # 100 => "#FACDD4",
      # 400 => "#F06A7D",
      # 500 => "#EB3851",
      # 600 => "#E60626",
      # # GREEN
      # 100 => "#C5F1D4",
      # 400 => "#3CD070",
      # 500 => "#30A65A",
      # 600 => "#247D43",
      # # ORANGE
      # 100 => "#FFECCC",
      # 400 => "#FFB435",
      # 500 => "#FFA102",
      # 600 => "#CC8102",
    },
    # chart_colors: ['#FFB435', "#FFA102", "#CC8102", '#FFB435', "#FFA102", "#CC8102"],
    logo: "/avo-assets/logo.png",
    logomark: "/avo-assets/logomark.png"
  }
  config.resource_controls_placement = if ENV["AVO_RESOURCE_CONTROLS_PLACEMENT"].present?
    ENV["AVO_RESOURCE_CONTROLS_PLACEMENT"].to_sym
  else
    :right
  end
  config.model_resource_mapping = {
    'User': 'UserResource'
  }
  config.set_context do
    {
      foo: "bar",
      user: current_user,
      params: request.params
    }
  end
  config.home_path = -> { avo.dashboard_path(:dashy) }
  config.set_initial_breadcrumbs do
    add_breadcrumb "Dashboard", "/admin/dashboards/dashy"
  end
  config.resource_default_view = :show
  config.search_debounce = 300
  config.main_menu = -> {

    section I18n.t("avo.dashboards"), icon: "dummy-adjustments.svg" do
      dashboard :dashy, visible: -> { true }
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
        resource :posts
        resource :comments
      end

      section "Store", icon: "currency-dollar" do
        resource :products
      end

      group "Other", collapsable: true, collapsed: true do
        resource :fish, label: "Fishies"
      end
    end

    section "Tools", icon: "bolt", collapsable: true, collapsed: true do
      all_tools
    end

    group do
      link "Avo", "https://avohq.io"
      link_to "Google", "https://google.com", target: :_blank
    end
  }
  config.profile_menu = -> {
    link "Profile", path: "/profile", icon: "user-circle"
  }
end
