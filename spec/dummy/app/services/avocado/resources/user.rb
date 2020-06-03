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
        id :ID
        text :Name, required: true
        file :cv, name: 'CV'
        file :avatar, is_avatar: true
        files :images, is_image: true
        files :docs
        text :email, name: 'User Email', required: true
        number :age, min: 0, max: 120, step: 5
        boolean :availability
        date :birthday, first_day_of_week: 1, picker_format: 'F J Y', format: 'MMMM Do YYYY', placeholder: 'Set the users birthday', required: true
        datetime :starts_on, placeholder: 'When the user should start', time_24hr: true
        select :highlighted, options: { yes: 'Highlighted', no: 'Not Highlighted' }, display_with_value: true
        password :password, name: 'User Password', required: false, except_on: :forms
        password :password_confirmation, name: 'Password confirmation', required: false
        text 'Is Writer', resolve_using: -> (value) { value.truncate 3 }, hide_on: :edit do |model, resource, view, field|
          model.posts.to_a.count > 0 ? 'yes' : 'no'
        end
        textarea :Description, rows: 5, readonly: false, hide_on: :index, resolve_using: -> (value) { value.to_s.truncate 30 }, required: true
        has_many :Projects
        has_many :Posts
      end

      use_filter Avocado::Filters::AvailableFilter
      # use_filter Avocado::Filters::FeaturedFilter
    end
  end
end
