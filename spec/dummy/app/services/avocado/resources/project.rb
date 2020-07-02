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
        status :Status, failed_when: ['closed', 'reject', 'failed'], loading_when: ['loading', 'running', 'waiting']
        has_and_belongs_to_many :users
      end
    end
  end
end
