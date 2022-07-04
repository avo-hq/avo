class UserResource < Avo::BaseResource
  self.title = :name
  self.description = -> {
    "Users of the app. view: #{view}"
  }
  self.translation_key = "avo.resource_translations.user"
  self.search_query = ->(params:) do
    scope.order(created_at: :desc).ransack(id_eq: params[:q], first_name_cont: params[:q], last_name_cont: params[:q], m: "or").result(distinct: false)
  end
  self.resolve_query_scope = ->(model_class:) do
    model_class.order(last_name: :asc)
  end
  self.resolve_find_scope = ->(model_class:) do
    model_class.friendly
  end
  self.includes = [:posts, :post]
  self.devise_password_optional = true

  field :id, as: :id, link_to_resource: true
  field :email, as: :gravatar, link_to_resource: true, as_avatar: :circle
  heading "User Information"
  field :first_name, as: :text, required: true, placeholder: "John"
  field :last_name, as: :text, required: true, placeholder: "Doe"
  field :email, as: :text, name: "User Email", required: true
  field :active, as: :boolean, name: "Is active", show_on: :show
  field :cv, as: :file, name: "CV"
  field :is_admin?, as: :boolean, name: "Is admin", only_on: :index
  field :roles, as: :boolean_group, options: {admin: "Administrator", manager: "Manager", writer: "Writer"}
  field :roles, as: :text, hide_on: :all, as_description: true do |model, resource, view, field|
    "This user has the following roles: #{model.roles.select { |key, value| value }.keys.join(", ")}"
  end
  field :birthday, as: :date, only_on: :index, first_day_of_week: 1, picker_format: "F J Y", format: "%Y-%m-%d", placeholder: "Feb 24th 1955", required: true
  field :is_writer, as: :text, format_using: ->(value) { value.truncate 3 }, sortable: ->(query, direction) {
    # Order by something else completely, just to make a test case that clearly and reliably does what we want.
    query.order(id: direction)
  }, hide_on: :edit do |model, resource, view, field|
    model.posts.to_a.size > 0 ? "yes" : "no"
  end

  field :password, as: :password, name: "User Password", required: false, except_on: :forms, help: 'You may verify the password strength <a href="http://www.passwordmeter.com/" target="_blank">here</a>.'
  field :password_confirmation, as: :password, name: "Password confirmation", required: false, only_on: :new

  heading '<div class="underline uppercase font-bold">DEV</div>', as_html: true
  field :custom_css, as: :code, theme: "dracula", language: "css", help: "This enables you to edit the user's custom styles.", height: "250px"
  field :team_id, as: :hidden, default: 0 # For testing purposes

  field :outside_link, as: :text, only_on: [:show], format_using: ->(url) { link_to("hey", url, target: "_blank") } do |model, *args|
    main_app.hey_url
  end

  tabs do
    tab "birthday", description: "hey you", hide_on: :show do
      panel do
        field :birthday, as: :date, first_day_of_week: 1, picker_format: "F J Y", format: "%Y-%m-%d", placeholder: "Feb 24th 1955", required: true
      end
    end

    field :post,
      as: :has_one,
      name: "Main post",
      translation_key: "avo.field_translations.people"

    field :posts,
      as: :has_many,
      show_on: :edit,
      attach_scope: -> { query.where.not(user_id: parent.id).or(query.where(user_id: nil)) }
    field :teams, as: :has_and_belongs_to_many
    field :people,
      as: :has_many,
      show_on: :edit,
      translation_key: "avo.field_translations.people"
    field :spouses, as: :has_many # STI has_many resource
    field :comments,
      as: :has_many,
      # show_on: :edit,
      scope: -> { query.starts_with parent.first_name[0].downcase },
      description: "The comments listed in the attach modal all start with the name of the parent user."
    field :projects, as: :has_and_belongs_to_many
  end


  grid do
    cover :email, as: :gravatar, link_to_resource: true
    title :name, as: :text, link_to_resource: true
    body :url, as: :text
  end

  action ToggleInactive
  action ToggleAdmin
  action DummyAction
  action DownloadFile

  filter UserNamesFilter
  filter IsAdmin
  filter DummyMultipleSelectFilter

  # field :email, as: :text

  # tabs do
  #   tab :MAAAIN do
  #     # main_panel
  #     panel :first_panel do
  #       field :id, as: :id, link_to_resource: true
  #       field :email, as: :text
  #       field :email, as: :gravatar, link_to_resource: true, as_avatar: :circle
  #     end

  #     tool AnnTool
  #   end

  #   tab I18n.t("avo.field_translations.people", count: 2) do
  #     panel do
  #       field :email, as: :text
  #     end
  #     field :people, as: :has_many, translation_key: "avo.field_translations.people", show_on: :edit
  #   end

  #   tab :post, description: 'Somethings about this post' do
  #     field :email, as: :text
  #     field :post, as: :has_one, translation_key: "avo.field_translations.people", name: "Main post"
  #   end
  # end

  # panel do
  #   field :last_name, as: :text, required: true, placeholder: "Doe"
  #   field :first_name, as: :text, required: true, placeholder: "John"
  # end

  # field :email, as: :gravatar, link_to_resource: true, as_avatar: :circle
  # heading "User Information"


  # field :email, as: :text, name: "User Email", required: true

  # tabs do
  #   tab :Main do
  #     panel :Data do
  #       field :email, as: :text, name: "UUUser Email", required: true
  #     end

  #     panel :Other do
  #       field :is_admin?, as: :boolean, name: "Is admin"
  #     end
  #     field :people, as: :has_many, translation_key: "avo.field_translations.people"

  #     tool AnnTool
  #     tool UserTool
  #   end
  #   tab :Other do
  #     tool MuserTool
  #     panel do
  #       field :email, as: :text, name: "User Email", required: true
  #       field :email, as: :text, name: "User Email", required: true
  #     end
  #   end
  #   tab :Other_2 do
  #     tool BobTool
  #   end
  # end
  # panel do
  #   field :first_name, as: :text
  #   field :last_name, as: :text
  # end

  # tool AnnTool

  # tabs do
  #   tab :Foo do
  #     panel do
  #       field :email, as: :text, name: "User Email", required: true
  #       field :email, as: :text, name: "User Email", required: true
  #     end
  #     tool AnnTool
  #   end
  #   tab :Baz do
  #     tool BobTool
  #   end
  # end


  # # # =============

  # panel do
  #   field :email, as: :text, name: "User Email", required: true
  #   field :email, as: :text, name: "User Email", required: true
  # end

  # field :active, as: :boolean, name: "Is active", show_on: :show
  # field :cv, as: :file, name: "CV"
  # field :is_admin?, as: :boolean, name: "Is admin", only_on: :index
  # field :roles, as: :boolean_group, options: {admin: "Administrator", manager: "Manager", writer: "Writer"}
  # field :roles, as: :text, hide_on: :all, as_description: true do |model, resource, view, field|
  #   "This user has the following roles: #{model.roles.select { |key, value| value }.keys.join(", ")}"
  # end
  # field :birthday, as: :date, first_day_of_week: 1, picker_format: "F J Y", format: "%Y-%m-%d", placeholder: "Feb 24th 1955", required: true
  # field :is_writer, as: :text, format_using: ->(value) { value.truncate 3 }, sortable: ->(query, direction) {
  #   # Order by something else completely, just to make a test case that clearly and reliably does what we want.
  #   query.order(id: direction)
  # }, hide_on: :edit do |model, resource, view, field|
  #   model.posts.to_a.size > 0 ? "yes" : "no"
  # end

  # field :password, as: :password, name: "User Password", required: false, except_on: :forms, help: 'You may verify the password strength <a href="http://www.passwordmeter.com/" target="_blank">here</a>.'
  # field :password_confirmation, as: :password, name: "Password confirmation", required: false, only_on: :new

  # panel do
  #   heading '<div class="underline uppercase font-bold">DEV</div>', as_html: true
  #   field :custom_css, as: :code, theme: "dracula", language: "css", help: "This enables you to edit the user's custom styles.", height: "250px"
  # end

  # field :post, as: :has_one, translation_key: "avo.field_translations.people", name: "Main post"

  # panel :hey, description: :yo do
  #   field :custom_css, as: :code, theme: "dracula", language: "css", help: "This enables you to edit the user's custom styles.", height: "250px"
  #   field :team_id, as: :hidden, default: 0 # For testing purposes

  #   field :outside_link, as: :text, only_on: [:show], format_using: ->(url) { link_to("hey", url, target: "_blank") } do |model, *args|
  #     main_app.hey_url
  #   end
  # end

  # tabs do
  #   field :birthday, as: :date, first_day_of_week: 1, picker_format: "F J Y", format: "%Y-%m-%d", placeholder: "Feb 24th 1955", required: true

  #   field :post, as: :has_one, translation_key: "avo.field_translations.people", name: "Main post"
  #   field :posts,
  #     as: :has_many,
  #     attach_scope: -> { query.where.not(user_id: parent.id).or(query.where(user_id: nil)) }
  #   tab :post do
  #   end
  #   tab :posts do
  #   end
  # end

  # tabs do
  #   field :teams, as: :has_and_belongs_to_many
  #   field :people, as: :has_many, translation_key: "avo.field_translations.people"
  # end

  # # field :posts,
  # #   as: :has_many,
  # #   attach_scope: -> { query.where.not(user_id: parent.id).or(query.where(user_id: nil)) }
  # # field :teams, as: :has_and_belongs_to_many
  # # field :people, as: :has_many, translation_key: "avo.field_translations.people", show_on: :edit
  # field :spouses, as: :has_many # STI has_many resource
  # field :comments,
  #   as: :has_many,
  #   scope: -> { query.starts_with parent.first_name[0].downcase },
  #   description: "The comments listed in the attach modal all start with the name of the parent user."
  # field :projects, as: :has_and_belongs_to_many

  # grid do
  #   cover :email, as: :gravatar, link_to_resource: true
  #   title :name, as: :text, link_to_resource: true
  #   body :url, as: :text
  # end

  # action ToggleInactive
  # action ToggleAdmin
  # action DummyAction
  # # action DownloadFile

  # filter UserNamesFilter
  # filter IsAdmin
  # filter DummyMultipleSelectFilter

  tool UserTool
end
