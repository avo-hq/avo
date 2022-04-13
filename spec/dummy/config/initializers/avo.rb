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
  config.main_menu = nil
  config.main_menu = -> {
    section I18n.t("avo.dashboards"), icon: "dashboards" do
      dashboard :dashy, visible: -> { true }
      dashboard :sales, visible: -> { true }

      group "All dashboards", visible: false do
        all_dashboards
      end
    end

    section "Resources", icon: "heroicons/outline/academic-cap" do
      group "Academia" do
        resource :course
        resource :course_link
      end

      group "Blog" do
        resource :posts
        resource :comments
      end

      group "Company" do
        resource :projects
        resource :team
        resource :reviews
      end

      group "People" do
        resource :users
        resource :people
        resource :spouses
      end

      group "Other" do
        resource :fish
      end
    end

    section "Tools", icon: "heroicons/outline/finger-print" do
      all_tools
    end

    group do
      link "Avo", path: "https://avohq.io"
      link "Google", path: "https://google.com", target: :_blank
    end
  }
end
