module Avocado
  module Resources
    class User < Resource
      def initialize
        @title = :name
        @search = [:name, :id, :description]
      end

      fields do
        id :ID
        text :Name, required: true
        text :email, name: 'User Email', required: true
        text 'User Password', required: true
        text :password_confirmation, name: 'Password confirmation', required: true
        text 'Is Writer' do |model, resource|
          model.posts.count > 0 ? 'yes' : 'no'
        end
        textarea :Description
        has_many :Posts
        has_many :Projects
      end

      use_filter Avocado::Filters::AvailableFilter
      # use_filter Avocado::Filters::FeaturedFilter
    end
  end
end