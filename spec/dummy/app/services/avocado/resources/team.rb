module Avocado
  module Resources
    class Team < Resource
      def initialize
        @title = :name
        @search = [:id, :name]
      end

      fields do
        id
        text :name
        textarea :description
        has_one :admin
        has_many :members
      end
    end
  end
end
