module Avo
  module Filters
    class MembersFilter < BooleanFilter
      def name
        'Members filter'
      end

      def apply(request, query, value)
        return query.where(id: Team.joins(:memberships).group('teams.id').count.keys) if value[:has_members]

        query
      end

      def default
        {
          has_members: true
        }
      end

      def options
        {
          'has_members': 'Has Members'
        }
      end
    end
  end
end
