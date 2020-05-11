module Avocado
  module Resources
    class Post < Resource
      def initialize
        @title = :name
        @search = [:name, :id]
      end

      fields do
        id :ID
        text :Name
        belongs_to :User
      end

      # use_filter Avocado::Filters::IndicatorFilter
      # use_filter Avocado::Filters::FeaturedFilter
    end
  end
end