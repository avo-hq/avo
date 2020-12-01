module Avo
  module Filters
    class StartedFilter < DateFilter
      def name
        'Started after filter'
      end

      def apply(request, query, value)
        if value
          date = Date.strptime(value, '%Y-%m-%d')

          query.where('started_at >= ?', date)
        else
          query
        end
      end

      def filter_configuration
        defaults = {
          range: false,
          first_day_of_week: 0,
          picker_format: 'Y-m-d',
          placeholder: 'Select a date',
        }

        return configuration.reverse_merge!(defaults) if defined? configuration

        defaults
      end
    end
  end
end
