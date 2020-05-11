module Avocado
  module Resources
    class User < Resource
      def initialize
        @title = :name
        @search = [:name, :id]
      end

      fields do
        id :ID
        text :Name, required: true
        text(:Foo, required: true) do |model, resource|
          "foo or bar #{model.id}, #{resource.name}"
        end
        has_many :Posts
        has_many :Projects
      end

      use_filter Avocado::Filters::AvailableFilter
      # use_filter Avocado::Filters::FeaturedFilter
    end
  end
end