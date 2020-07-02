module Avocado
  module Resources
    class Project < Resource
      def initialize
        @title = :name
        @search = [:name, :id]
        @includes = :users
      end

      fields do
        id
        text :name, required: true
        status :status, failed_when: [:closed, :rejected, :failed], loading_when: [:loading, :running, :waiting]
        has_and_belongs_to_many :users
      end
    end
  end
end
