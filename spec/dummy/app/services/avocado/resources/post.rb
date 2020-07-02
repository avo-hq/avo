module Avocado
  module Resources
    class Post < Resource
      def initialize
        @title = :name
        @search = [:name, :id]
        @includes = :user
      end

      fields do
        id
        text :name, required: true
        textarea :body
        belongs_to :user, searchable: false, placeholder: '-'
        boolean :featured
      end

      use_filter Avocado::Filters::FeaturedFilter
    end
  end
end
