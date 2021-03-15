class UserResource < Avo::BaseResource
  self.title = :name
  self.translation_key = 'avo.resource_translations.user'
  self.search = [:id, :first_name, :last_name]
  self.includes = [:posts, :post]
  self.devise_password_optional = true

  puts 'USerResource'.inspect
  # Rails.autoloaders.main.reload
  # reload!




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

  # grid do |preview, title, body|
  #   card.gravatar :email, grid_position: :preview, link_to_resource: true
  #   card.text :name, grid_position: :title, link_to_resource: true
  #   card.text :url, grid_position: :body
  # end



  # stage 1
  # def fields # index, show, forms


  #   # field.heading 'User Information'

  #   # panel 'User Information' do
  #     field.text :first_name, required: true, placeholder: 'John', default: 'default'
  #     field.text :last_name, required: true, placeholder: 'Doe'
  #     field.text :email, name: 'User Email', required: true
  #     field.boolean :active, name: 'Is active', show_on: [:show, :forms]
  #     field.file :cv, name: 'CV'
  #     field.boolean :is_admin?, name: 'Is admin', only_on: :index
  #     field.boolean_group :roles, options: { admin: 'Administrator', manager: 'Manager', writer: 'Writer' }
  #     field.date :birthday, first_day_of_week: 1, picker_format: 'F J Y', format: '%Y-%m-%d', placeholder: 'Feb 24th 1955', required: true
  #     field.text :is_writer, format_using: -> (value) { value.truncate 3 }, hide_on: :edit do |model, resource, view, field|
  #       model.posts.to_a.count > 0 ? 'yes' : 'no'
  #     end
  #     field.text :excerpt, hide_on: [:index, :show, :forms]
  #   # end

  #   field.password :password, name: 'User Password', required: false, except_on: :forms, help: 'You may verify the password strength <a href="http://www.passwordmeter.com/" target="_blank">here</a>.'
  #   field.password :password_confirmation, name: 'Password confirmation', required: false, only_on: :new

  #   field.heading '<div class="text-gray-300 uppercase font-bold">DEV</div>', as_html: true
  #   field.code :custom_css, theme: 'dracula', language: 'css', help: "This enables you to edit the user's custom styles.", height: '250px'

  #   field.hidden :team_id, default: 0 # For testing purposes

  #   field.has_one :post
  #   field.has_many :posts
  #   field.has_and_belongs_to_many :projects
  #   field.has_and_belongs_to_many :teams
  # end


  # # Stage 2
  # def definition # index, show, forms
  #   field.id :id, link_to_resource: true
  #   field.gravatar :email, link_to_resource: true

  #   # field.heading 'User Information'

  #   # panel 'User Information' do
  #   field.text :first_name, required: true, placeholder: 'John', default: 'default'
  #   field.text :last_name, required: true, placeholder: 'Doe'
  #   field.text :email, name: 'User Email', required: true
  #     field.boolean :active, name: 'Is active', show_on: [:show, :forms]
  #     field.file :cv, name: 'CV'
  #     field.boolean :is_admin?, name: 'Is admin', only_on: :index
  #     field.boolean_group :roles, options: { admin: 'Administrator', manager: 'Manager', writer: 'Writer' }
  #     field.date :birthday, first_day_of_week: 1, picker_format: 'F J Y', format: '%Y-%m-%d', placeholder: 'Feb 24th 1955', required: true
  #     field.text :is_writer, format_using: -> (value) { value.truncate 3 }, hide_on: :edit do |model, resource, view, field|
  #       model.posts.to_a.count > 0 ? 'yes' : 'no'
  #     end
  #     field.text :excerpt, hide_on: [:index, :show, :forms]
  #   # end

  #   field.password :password, name: 'User Password', required: false, except_on: :forms, help: 'You may verify the password strength <a href="http://www.passwordmeter.com/" target="_blank">here</a>.'
  #   field.password :password_confirmation, name: 'Password confirmation', required: false, only_on: :new

  #   field.heading '<div class="text-gray-300 uppercase font-bold">DEV</div>', as_html: true
  #   field.code :custom_css, theme: 'dracula', language: 'css', help: "This enables you to edit the user's custom styles.", height: '250px'

  #   field.hidden :team_id, default: 0 # For testing purposes

  #   field.has_one :post
  #   field.has_many :posts
  #   field.has_and_belongs_to_many :projects
  #   field.has_and_belongs_to_many :teams
  # end

  # def index
  #   column :first_name
  #   column :last_name
  #   column :email

  #   column :custom_css

  #   column :team_id

  #   column :team
  # end

  # def show
  #   field :first_name
  #   field :last_name
  #   field :email

  #   section do
  #     field :active
  #     field :cv
  #     field :is_admin
  #     field :roles
  #   end

  #   panel do
  #     field :is_writer
  #     field :excerpt
  #     field :password
  #     field :password_confirmation
  #   end
  #   field :birthday

  #   field :custom_css

  #   field :team_id

  #   field :pos
  #   field :post
  #   field :project
  #   field :team
  # end

  # def grid
  #   g.preview :email
  #   g.title :name
  #   g.body :grid_excerpt
  # end

  # def grid_excerpt
  #   model.body.truncate 130
  # end

  # def feed
  #   g.preview :email
  #   g.title :name
  #   g.body :feed_excerpt
  # end

  # def feed_excerpt
  #   model.body.truncate 300
  # end

  # def grid
  #   g.gravatar :email, grid_position: :preview, link_to_resource: true
  #   g.text :name, grid_position: :title, link_to_resource: true
  #   g.text :url, grid_position: :body
  # end

  # def feed
  #   g.gravatar :email, grid_position: :preview, link_to_resource: true
  #   g.text :name, grid_position: :title, link_to_resource: true
  #   g.text :url, grid_position: :body
  # end

  # def actions
  #   a.use ToggleInactive
  #   a.use ToggleAdmin
  # end
end
