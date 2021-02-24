module Avo
  module Resources
    class User < Resource
      def configure
        @title = :name
        @translation_key = 'avo.resource_translations.user'
        @search = [:id, :first_name, :last_name]
        @includes = [:posts, :post]
        @has_devise_password = true
        # @name = 'usy'
      end

      def fields(request)
        f.id :id, link_to_resource: true
        f.gravatar :email, link_to_resource: true
        f.heading 'User Information'
        f.text :first_name, required: true, placeholder: 'John', default: 'default'
        f.text :last_name, required: true, placeholder: 'Doe'
        f.text :email, name: 'User Email', required: true
        f.boolean :active, name: 'Is active', show_on: :show
        # file :cv, name: 'CV'
        # boolean :is_admin?, name: 'Is admin', only_on: :index
        # boolean_group :roles, options: { admin: 'Administrator', manager: 'Manager', writer: 'Writer' }
        f.date :birthday, first_day_of_week: 1, picker_format: 'F J Y', format: '%Y-%m-%d', placeholder: 'Feb 24th 1955', required: true
        # text :is_writer, format_using: -> (value) { value.truncate 3 }, hide_on: :edit do |model, resource, view, field|
        #   model.posts.to_a.count > 0 ? 'yes' : 'no'
        # end

        f.password :password, name: 'User Password', required: false, except_on: :forms, help: 'You may verify the password strength <a href="http://www.passwordmeter.com/" target="_blank">here</a>.'
        f.password :password_confirmation, name: 'Password confirmation', required: false, only_on: :new

        f.heading '<div class="text-gray-300 uppercase font-bold">DEV</div>', as_html: true
        f.code :custom_css, theme: 'dracula', language: 'css', help: "This enables you to edit the user's custom styles.", height: '250px'

        # hidden :team_id, default: 0 # For testing purposes

        # f.has_one :post
        f.has_many :posts
        f.has_and_belongs_to_many :projects
        f.has_and_belongs_to_many :teams
      end

      def actions(request)
        a.use Avo::Actions::MarkInactive
        a.use Avo::Actions::MakeAdmin
      end
    end
  end
end
