Avo.configure do |config|
  config.root_path = "/admin"
  config.app_name = "Avocadelicious"
  config.license = "pro"
  config.locale = "en-US"
  config.license_key = ENV["AVO_LICENSE_KEY"]
  config.current_user_method = :current_user
  config.id_links_to_resource = true
  config.full_width_container = true
  config.set_context do
    {
      foo: "bar",
      user: current_user,
      params: request.params
    }
  end
  config.home_path = "/admin/dashboard"
  config.set_initial_breadcrumbs do
    add_breadcrumb "Dashboard", "/admin/dashboard"
  end
  config.search_debounce = 300
  config.main_menu = -> {
    section I18n.t("avo.dashboards"), icon: "dashboards" do
      dashboard :dashy, visible: -> { true }
      dashboard "Sales", visible: -> { true }

      group "All dashboards", visible: false, collapsable: true do
        all_dashboards
      end
    end

    section "Resources", icon: "heroicons/outline/academic-cap", collapsable: true, collapsed: false do
      group "Company", collapsable: true do
        resource :projects
        resource :team
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

      group "Other", collapsable: true, collapsed: true do
        resource :fish
      end
    end

    section "Tools", icon: "heroicons/outline/finger-print", collapsable: true, collapsed: true do
      all_tools
    end

    group do
      link "Avo", path: "https://avohq.io"
      link "Google", path: "https://google.com", target: :_blank
    end
  }
  config.profile_menu = -> {
    link "Profile", path: "/profile", icon: "user-circle"
  }
end
