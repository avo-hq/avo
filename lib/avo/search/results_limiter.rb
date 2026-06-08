# frozen_string_literal: true

module Avo
  module Search
    module ResultsLimiter
      def self.apply(query)
        return query if query.is_a?(Array)

        query = query.all if query.is_a?(Class)
        return query if query.limit_value.present?

        query.limit(Avo.configuration.search_results_count)
      end
    end
  end
end
