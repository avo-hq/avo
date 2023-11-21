class Avo::Resources::User < Avo::BaseResource
  self.title = -> {
    record.name
  }
  self.description = -> {
    description = "Users of the app. view: #{view}"
    if !view.index?
      description = "#{description}, name: #{record.name}"
    end
    description
  }
  self.translation_key = "avo.resource_translations.user"
  self.search = {
    query: -> {
      query.order(created_at: :desc)
        .ransack(id_eq: params[:q], first_name_cont: params[:q], last_name_cont: params[:q], m: "or")
        .result(distinct: false)
    }
  }
  self.index_query = -> do
    query.order(last_name: :asc)
  end
  self.find_record_method = -> {
    # When using friendly_id, we need to check if the id is a slug or an id.
    # If it's a slug, we need to use the find_by_slug method.
    # If it's an id, we need to use the find method.
    # If the id is an array, we need to use the where method in order to return a collection.
    if id.is_a?(Array)
      (id.first.to_i == 0) ? query.where(slug: id) : query.where(id: id)
    else
      (id.to_i == 0) ? query.find_by_slug(id) : query.find(id)
    end
  }
  self.includes = [:posts, :post]
  self.devise_password_optional = true
  self.grid_view = {
    card: -> do
      {
        cover_url: record.avatar,
        title: record.name
      }
    end
  }

  def fields
    test_field("Heading")

    main_panel do
      main_panel_fields
    end

    user_information_panel

    first_tabs_group
    second_tabs_group

    tool Avo::ResourceTools::UserTool

    # Uncomment this to test computed file fields
    # field :first_post_image, as: :file, is_image: true do
    #   record&.posts&.first&.cover_photo
    # end
  end

  def actions
    action Avo::Actions::ToggleInactive
    action Avo::Actions::ToggleAdmin
    action Avo::Actions::Sub::DummyAction
    action Avo::Actions::DownloadFile
  end

  def filters
    filter Avo::Filters::UserNamesFilter
    filter Avo::Filters::IsAdmin
    filter Avo::Filters::DummyMultipleSelectFilter
  end

  def test_field(id)
    return unless ENV['testing_methods']

    field id.to_sym, as: :text do
      id
    end
  end

  def the_fish
    field :fish, as: :has_one
  end

  def main_panel_fields
    test_field("Inside main panel")
    field :id, as: :id, link_to_record: true, sortable: false
    field :email, as: :gravatar, link_to_record: true, as_avatar: :circle, only_on: :index
    with_options as: :text, only_on: :index do
      field :first_name, placeholder: "John"
      field :last_name, placeholder: "Doe", filterable: true
    end
    field :email, as: :text, name: "User Email", required: true, protocol: :mailto
    field :active, as: :boolean, name: "Is active", only_on: :index
    field :cv, as: :file, name: "CV"
    field :is_admin?, as: :boolean, name: "Is admin", only_on: :index
    field :roles, as: :boolean_group, options: {admin: "Administrator", manager: "Manager", writer: "Writer"}
    field :birthday,
      as: :date,
      first_day_of_week: 1,
      picker_format: "F J Y",
      format: "cccc, d LLLL yyyy", # Wednesday, 10 February 1988
      placeholder: "Feb 24th 1955",
      required: true,
      only_on: [:index]

    field :is_writer, as: :text,
      sortable: -> {
        # Order by something else completely, just to make a test case that clearly and reliably does what we want.
        query.order(id: direction)
      },
      hide_on: :edit do
        record.posts.to_a.size > 0 ? "yes" : "no"
      end

    field :password, as: :password, name: "User Password", required: false, only_on: :forms, help: 'You may verify the password strength <a href="http://www.passwordmeter.com/" target="_blank">here</a>.'
    field :password_confirmation, as: :password, name: "Password confirmation", required: false

    field :dev, as: :heading, label: '<div class="underline uppercase font-bold">DEV</div>', as_html: true
    field :custom_css, as: :code, theme: "dracula", language: "css", help: "This enables you to edit the user's custom styles.", height: "250px"
    field :team_id, as: :hidden, default: 0 # For testing purposes

    test_sidebar

    main_panel_sidebar
  end

  def test_sidebar
    return unless ENV['testing_methods']

    sidebar panel_wrapper: false do
      tool Avo::ResourceTools::SidebarTool, render_panel: true
      test_field("Inside test_sidebar")
    end
  end

  def main_panel_sidebar
    sidebar do
      test_field("Inside main_panel_sidebar")
      with_options only_on: :show do
        field :email, as: :gravatar, link_to_record: true, as_avatar: :circle
        field :heading, as: :heading, label: ""
        field :active, as: :boolean, name: "Is active"
      end
      field :is_admin?, as: :boolean, name: "Is admin", only_on: :index
      field :birthday,
        as: :date,
        first_day_of_week: 1,
        picker_format: "F J Y",
        format: "cccc, d LLLL yyyy", # Wednesday, 10 February 1988
        placeholder: "Feb 24th 1955",
        required: true,
        filterable: true,
        only_on: [:show]
      field :is_writer, as: :text,
        hide_on: :edit do
          raise "This should not execut on Index" if view.index?

          record.posts.to_a.size > 0 ? "yes" : "no"
        end
      field :outside_link, as: :text, only_on: [:show], format_using: -> { link_to("hey", value, target: "_blank") } do
        main_app.hey_url
      end
    end
  end

  def user_information_panel
    panel do
      test_field("Inside panel")

      field :user_information, as: :heading
      row do
        test_field("Inside panel -> row")
        stacked_name
      end

      panel_test_sidebars
    end
  end

  def panel_test_sidebars
    return unless ENV['testing_methods']

    sidebar do
      field :sidebar_test, as: :text do
        ";)"
      end
      test_field("Inside panel -> sidebar")
    end

    sidebar do
      field :sidebar_test_2, as: :text do
        "another ;)"
      end
      test_field("Inside panel -> sidebar 2")
      tool Avo::ResourceTools::SidebarTool
    end
  end

  def stacked_name
    with_options as: :text, stacked: true do
      field :first_name, placeholder: "John"
      field :last_name, placeholder: "Doe"
    end
  end

  def first_tabs_group
    tabs do
      birthday_tab
      test_tab
      test_field("Inside tabs")
      first_tabs_group_fields
    end
  end

  def second_tabs_group
    tabs do
      field :post,
        as: :has_one,
        name: "Main post",
        translation_key: "avo.field_translations.people"
      field :posts,
        as: :has_many,
        show_on: :edit,
        attach_scope: -> { query.where.not(user_id: parent.id).or(query.where(user_id: nil)) }
      field :comments,
        as: :has_many,
        # show_on: :edit,
        scope: -> { query.starts_with parent.first_name[0].downcase },
        description: "The comments listed in the attach modal all start with the name of the parent user."
    end
  end

  def birthday_tab
    tab -> { "Birthday" }, description: "hey you", hide_on: :show do
      panel do
        field :birthday,
          as: :date,
          first_day_of_week: 1,
          picker_format: "F J Y",
          format: "DDDD",
          placeholder: "Feb 24th 1955",
          required: true
      end
    end
  end

  def test_tab
    return unless ENV['testing_methods']

    tab "test_tab" do
      panel do
        test_field("Inside tabs -> tab -> panel")
      end

      test_field("Inside tabs -> tab")
    end
  end

  def first_tabs_group_fields
    the_fish
    field :teams, as: :has_and_belongs_to_many
    field :people,
      as: :has_many,
      show_on: :edit,
      translation_key: "avo.field_translations.people"
    field :spouses, as: :has_many # STI has_many resource
    field :projects, as: :has_and_belongs_to_many
    field :team_memberships, as: :has_many
  end
end
