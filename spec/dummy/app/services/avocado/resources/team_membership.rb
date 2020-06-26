module Avocado
  module Resources
    class TeamMembership < Resource
      def initialize
        @title = :id
        @search = :id
      end

      fields do
        id :ID
        select :level, options: { rookie: 'Rookie', manager: 'Manager', executive: 'Executive' }
        belongs_to :User
        belongs_to :Team
      end
    end
  end
end
