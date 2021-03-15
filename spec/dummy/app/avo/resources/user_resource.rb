class UserResource < Avo::BaseResource
  self.title = :name
  self.translation_key = 'avo.resource_translations.user'
  self.search = [:id, :first_name, :last_name]
  self.includes = [:posts, :post]
  self.devise_password_optional = true

  fields do |field|
    field.id :id, link_to_resource: true
    field.gravatar :email, link_to_resource: true
    field.heading 'User Information'
    field.text :first_name, required: true, placeholder: 'John', default: 'default'
    field.text :last_name, required: true, placeholder: 'Doe'
    field.text :email, name: 'User Email', required: true
    field.boolean :active, name: 'Is active', show_on: :show
    field.file :cv, name: 'CV'
    field.boolean :is_admin?, name: 'Is admin', only_on: :index
    field.boolean_group :roles, options: { admin: 'Administrator', manager: 'Manager', writer: 'Writer' }
    field.date :birthday, first_day_of_week: 1, picker_format: 'F J Y', format: '%Y-%m-%d', placeholder: 'Feb 24th 1955', required: true
    field.text :is_writer, format_using: -> (value) { value.truncate 3 }, hide_on: :edit do |model, resource, view, field|
      model.posts.to_a.count > 0 ? 'yes' : 'no'
    end

    field.password :password, name: 'User Password', required: false, except_on: :forms, help: 'You may verify the password strength <a href="http://www.passwordmeter.com/" target="_blank">here</a>.'
    field.password :password_confirmation, name: 'Password confirmation', required: false, only_on: :new

    field.heading '<div class="text-gray-300 uppercase font-bold">DEV</div>', as_html: true
    field.code :custom_css, theme: 'dracula', language: 'css', help: "This enables you to edit the user's custom styles.", height: '250px'

    field.hidden :team_id, default: 0 # For testing purposes

    field.has_one :post
    field.has_many :posts
    field.has_and_belongs_to_many :projects
    field.has_and_belongs_to_many :teams
  end

  grid do |cover, title, body|
    cover.gravatar :email, link_to_resource: true
    title.text :name, link_to_resource: true
    body.text :url
  end

  actions do |a|
    a.use ToggleInactive
    a.use ToggleAdmin
  end
end
