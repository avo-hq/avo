module Avo
  module Resources
    class TeamMembership < Resource
      def initialize
        @title = :id
        @search = :id
      end

      fields do
        id
        select :level, options: { beginner: 'Beginner', intermediate: 'Intermediate', advanced: 'Advanced' }, default: -> (model, resource, view, field) { Time.now.hour < 12 ? 'advanced' : 'beginner' }
        belongs_to :user
        belongs_to :team
      end
    end
  end
end
