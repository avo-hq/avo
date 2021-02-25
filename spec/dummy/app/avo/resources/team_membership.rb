module Avo
  module Resources
    class TeamMembership < Resource
      def configure
        @title = :id
        @search = :id
        @includes = [:user, :team]
      end

      def fields(request)
        f.id
        f.select :level, options: { 'Beginner': :beginner, 'Intermediate': :intermediate, 'Advanced': :advanced }, display_value: true, default: -> (model, resource, view, field) { Time.now.hour < 12 ? 'advanced' : 'beginner' }
        f.belongs_to :user
        f.belongs_to :team
      end
    end
  end
end
