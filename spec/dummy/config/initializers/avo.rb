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
  config.menu = -> {
    section "Dahsboard", icon: "heroicons/outline/academic-cap" do
      dashboard "Dashy"
      dashboard :dashy
      item "Dashy"
      item "Blank"
      rest_of_dashboards
    end
    section "Resources" do
      resource :user
      group "Users" do
        item "Course Link"
      end
      item "users"
      rest_of_resources
    end
    section "Tools" do
      item "Some"
      item "thing"
      item "custom"
      rest_of_tools
    end

    item "avo", path: "https://avohq.io"
    item "google", path: "https://google.com", target: :_blank

    # item :see1

    # section "Seection", collapsable: false do
    #   group "Group", collapsable: true do
    #     item :lol
    #   end

    #   item :lol
    # end

    # group "Group 2" do
    #   item :lol2
    # end
    # section "section 2" do
    #   item :lol3
    # end
    # item :see4
  }
end
