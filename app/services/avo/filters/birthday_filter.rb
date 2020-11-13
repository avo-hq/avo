module Avo
  module Filters
    class BirthdayFilter < DateFilter
      def name
        'Birthday filter'
      end

      def apply(request, query, value)
        if value
          if value.include? 'to'
            dates = value.split(' to ').map { |date| Date.strptime(date.strip, '%Y-%m-%d') }

            start_date = dates[0]
            end_date = dates[1]

            query.where('birthday BETWEEN ? AND ?', start_date, end_date)
          else
            date = Date.strptime(value, '%Y-%m-%d')

            query.where('birthday > ?', date)
          end
        else
          query
        end
      end

      def configuration
        {
          placeholder: 'Select a range',
          range: true,
          picker_format: 'J M y',
          first_day_of_week: 1,
        }
      end
    end
  end
end
