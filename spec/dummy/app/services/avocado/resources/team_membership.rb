module Avocado
  module Resources
    class TeamMembership < Resource
      def initialize
        @title = :id
        @search = :id
      end

      fields do
        id
        select :level, options: { rookie: 'Rookie', manager: 'Manager', executive: 'Executive' }
        belongs_to :user
        belongs_to :team
      end
    end
  end
end
