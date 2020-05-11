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
        has_many :Posts
        has_many :Projects
      end

      use_filter Avocado::Filters::AvailableFilter
      # use_filter Avocado::Filters::FeaturedFilter
    end
  end
end