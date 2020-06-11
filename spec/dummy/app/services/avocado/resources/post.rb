module Avocado
  module Resources
    class Post < Resource
      def initialize
        @title = :name
        @search = [:name, :id]
        @includes = :user
      end

      fields do
        id :ID
        text :Name, required: true
        textarea :Body
        belongs_to :user, searchable: false, placeholder: '-'
      end

      # use_filter Avocado::Filters::IndicatorFilter
      # use_filter Avocado::Filters::FeaturedFilter
    end
  end
end
