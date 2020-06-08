module Avocado
  module Resources
    class Project < Resource
      def initialize
        @title = :name
        @search = [:name, :id]
        @includes = :users
      end

      fields do
        id :ID
        text :Name, required: true
        has_many :Users
      end

      # use_filter Avocado::Filters::IndicatorFilter
      # use_filter Avocado::Filters::FeaturedFilter
    end
  end
end
