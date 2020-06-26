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
        status :Status, failed_when: ['stricat', 'closed', 'reject', 'failed'], loading_when: ['loading', 'running', 'waiting', 'asteapta']
      end

      # use_filter Avocado::Filters::IndicatorFilter
      # use_filter Avocado::Filters::FeaturedFilter
    end
  end
end
