module Avocado
  module Resources
    class Team < Resource
      def initialize
        @title = :name
        @search = [:id, :name]
      end

      fields do
        id :ID
        text :name
        textarea :description
        # has_many :memberships
      end
    end
  end
end
