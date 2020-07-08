module Avocado
  module Resources
    class User < Resource
      def initialize
        @title = :name
        @search = [:name, :id, :description]
        @includes = :posts
        @has_devise_password = true
      end

      fields do
        id
        hidden :group_id
        gravatar :email
        text :name, required: true, placeholder: 'John Doe'
        currency :salary, currency: 'EUR', locale: 'de-DE'
        file :cv, name: 'CV'
        heading '<div class="text-blue-900 uppercase font-bold">Files</div>', as_html: true
        file :avatar, is_avatar: true
        files :images, is_image: true
        heading 'Other'
        country :country
        files :docs
        text :email, name: 'User Email', required: true
        number :age, min: 0, max: 120, step: 5
        boolean :is_admin?, name: 'Is admin', only_on: :index
        boolean :availability
        boolean_group :roles, options: { admin: 'Administrator', manager: 'Manager', write: 'Writer' }
        key_value :meta, key_label: 'Meta key', value_label: 'Meta value', action_text: 'New item', delete_text: 'Remove item', disable_editing_keys: false, disable_adding_rows: false, disable_deleting_rows: false
        date :birthday, first_day_of_week: 1, picker_format: 'F J Y', format: 'MMMM Do YYYY', placeholder: 'Feb 24th 1955', required: true
        datetime :starts_on, time_24hr: true
        select :highlighted, options: { yes: 'Highlighted', no: 'Not Highlighted' }, display_with_value: true, placeholder: 'This shows whether the user is highlighted'
        password :password, name: 'User Password', required: false, except_on: :forms
        password :password_confirmation, name: 'Password confirmation', required: false
        text :is_writer, format_using: -> (value) { value.truncate 3 }, hide_on: :edit do |model, resource, view, field|
          model.posts.to_a.count > 0 ? 'yes' : 'no'
        end
        textarea :description, rows: 5, readonly: false, hide_on: :index, format_using: -> (value) { value.to_s.truncate 30 }, required: true
        code :custom_css, theme: 'dracula', language: 'css'
        has_and_belongs_to_many :projects
        has_many :posts
      end

      use_filter Avocado::Filters::AvailabilityFilter
    end
  end
end
