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
        badge :stage, map: { info: [:discovery, :ideea], success: :done, warning: 'on hold', danger: :cancelled }
        has_and_belongs_to_many :users
      end
    end
  end
end
