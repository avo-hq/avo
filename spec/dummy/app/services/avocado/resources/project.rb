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
        badge :condition, map: { informations: 'info', failure: 'danger', cancelled: 'danger', info: 'success' }
        has_and_belongs_to_many :users
      end

      # use_filter Avocado::Filters::IndicatorFilter
      # use_filter Avocado::Filters::FeaturedFilter
    end
  end
end
