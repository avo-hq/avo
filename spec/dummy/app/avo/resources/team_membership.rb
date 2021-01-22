module Avo
  module Resources
    class TeamMembership < Resource
      def init
        @title = :id
        @search = :id
      end

      def fields(request)
        f.id
        # f.select :level, options: { beginner: 'Beginner', intermediate: 'Intermediate', advanced: 'Advanced' }, display_value: true, default: -> (model, resource, view, field) { Time.now.hour < 12 ? 'advanced' : 'beginner' }
        # f.belongs_to :user
        # f.belongs_to :team
      end
    end
  end
end
