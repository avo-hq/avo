class UserResource < Avo::BaseResource
  self.title = :name
  self.translation_key = "avo.resource_translations.user"
  self.search_query = ->(params:) do
    scope.ransack(id_eq: params[:q], first_name_cont: params[:q], last_name_cont: params[:q], m: "or").result(distinct: false)
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
  field :birthday, as: :date, first_day_of_week: 1, picker_format: "F J Y", format: "%Y-%m-%d", placeholder: "Feb 24th 1955", required: true
  field :is_writer, as: :text, format_using: ->(value) { value.truncate 3 }, hide_on: :edit do |model, resource, view, field|
    model.posts.to_a.size > 0 ? "yes" : "no"
  end

  field :password, as: :password, name: "User Password", required: false, except_on: :forms, help: 'You may verify the password strength <a href="http://www.passwordmeter.com/" target="_blank">here</a>.'
  field :password_confirmation, as: :password, name: "Password confirmation", required: false, only_on: :new

  heading '<div class="text-gray-300 uppercase font-bold">DEV</div>', as_html: true
  field :custom_css, as: :code, theme: "dracula", language: "css", help: "This enables you to edit the user's custom styles.", height: "250px"
  field :team_id, as: :hidden, default: 0 # For testing purposes

  field :post, as: :has_one
  field :posts, as: :has_many
  field :projects, as: :has_and_belongs_to_many
  field :teams, as: :has_and_belongs_to_many

  grid do
    cover :email, as: :gravatar, link_to_resource: true
    title :name, as: :text, link_to_resource: true
    body :url, as: :text
  end

  action ToggleInactive
  action ToggleAdmin
end
