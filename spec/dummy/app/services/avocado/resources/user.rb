module Avocado
  module Resources
    class User < Resource
      def initialize
        @title = :name
        @search = [:name, :id, :description]
      end

      fields do
        id
        text :Name, required: true, only_on: [:forms, :index]
        text :email, name: 'User Email', required: true, hide_on: :edit
        number :age
        password :password, name: 'User Password', required: true, except_on: :forms
        password :password_confirmation, name: 'Password confirmation', required: true
        text 'Is Writer' do |model, resource|
          model.posts.count > 0 ? 'yes' : 'no'
        end
        textarea :Description, except_on: :edit, rows: 5
        has_many :Posts
        has_many :Projects
      end

      use_filter Avocado::Filters::AvailableFilter
      # use_filter Avocado::Filters::FeaturedFilter
    end
  end
end