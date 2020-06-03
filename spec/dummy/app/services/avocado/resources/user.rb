module Avocado
  module Resources
    class User < Resource
      def initialize
        @title = :name
        @search = [:name, :id, :description]
        @includes = :posts
      end

      fields do
        id :ID
        text :Name, required: true
        file :cv, name: 'CV'
        file :avatar, is_avatar: true
        files :images, is_image: true
        files :docs
        text :email, name: 'User Email', required: true
        number :age, min: 0, max: 120, step: 1
        boolean :availability
        date :birthday, first_day_of_week: 1, picker_format: 'F J Y', format: 'MMMM Do YYYY', placeholder: 'Set the users birthday'
        datetime :starts_on, placeholder: 'When the user should start', time_24hr: true
        select :highlighted, options: { yes: 'Highlighted', no: 'Not Highlighted' }, display_with_value: true
        booleangroup :roles, options: { 'admin': 'Administrator', 'manager': 'Manager' }
        # password :password, name: 'User Password', required: true, except_on: :forms
        # password :password_confirmation, name: 'Password confirmation', required: true
        text 'Is Writer', resolve_using: -> (value) { value.truncate 3 }, hide_on: :edit do |model, resource, view, field|
          model.posts.to_a.count > 0 ? 'yes' : 'no'
        end
        textarea :Description, rows: 5, readonly: true, hide_on: :index, resolve_using: -> (value) { value.truncate 30 }
        has_many :Posts
        has_many :Projects
      end

      use_filter Avocado::Filters::AvailableFilter
      # use_filter Avocado::Filters::FeaturedFilter
    end
  end
end
