module Avo
  module Resources
    class User < Resource
      def initialize
        @title = :name
        @search = [:id, :first_name, :last_name]
        @includes = :posts
        @has_devise_password = true
      end

      fields do
        id
        gravatar :email, link_to_resource: true
        heading 'User information'
        text :first_name, required: true, placeholder: 'John'
        text :last_name, required: true, placeholder: 'Doe'
        text :email, name: 'User Email', required: true
        boolean :active, name: 'Is active', show_on: :show
        file :cv, name: 'CV'
        boolean :is_admin?, name: 'Is admin', only_on: :index
        boolean_group :roles, options: { admin: 'Administrator', manager: 'Manager', writer: 'Writer' }
        date :birthday, first_day_of_week: 1, picker_format: 'F J Y', format: 'MMMM Do YYYY', placeholder: 'Feb 24th 1955', required: true
        text :is_writer, format_using: -> (value) { value.truncate 3 }, hide_on: :edit do |model, resource, view, field|
          model.posts.to_a.count > 0 ? 'yes' : 'no'
        end

        password :password, name: 'User Password', required: false, except_on: :forms, help: 'You may verify the password strength <a href="http://www.passwordmeter.com/">here</a>.'
        password :password_confirmation, name: 'Password confirmation', required: false, only_on: :create

        heading '<div class="text-gray-300 uppercase font-bold">DEV</div>', as_html: true
        code :custom_css, theme: 'dracula', language: 'css', help: "This enables you to edit the user's custom styles.", height: '125px'

        hidden :team_id, default: 0 # For testing purposes

        has_and_belongs_to_many :projects
        has_many :posts
      end

      use_action Avo::Actions::MarkInactive
      use_action Avo::Actions::MakeAdmin
    end
  end
end
