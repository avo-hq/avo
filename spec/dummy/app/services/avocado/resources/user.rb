module Avocado
  module Resources
    class User < Resource
      def initialize
        @title = :name
        @search = [:name, :id]
      end

      fields do
        id
        text :Name, required: true
        text :Foo do |model, resource|
          "foo or bar #{model.id}, #{resource.name}"
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