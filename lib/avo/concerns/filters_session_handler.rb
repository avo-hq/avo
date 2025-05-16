module Avo
  module Concerns
    module FiltersSessionHandler
      def reset_filters
        return unless Avo.configuration.session_persistence_enabled?

        session.delete(filters_session_key)
      end

      def fetch_filters
        return filters_from_params unless Avo.configuration.session_persistence_enabled?

        (filters_from_params && save_filters_to_session) || filters_from_session
      end

      def filters_from_params
        params[Avo::Filters::BaseFilter::PARAM_KEY].presence
      end

      def save_filters_to_session
        session[filters_session_key] = params[Avo::Filters::BaseFilter::PARAM_KEY]
      end

      def filters_from_session
        session[filters_session_key]
      end

      def filters_session_key
        @filters_session_key ||= "/encoded_filters/" << %w[
          turbo_frame controller resource_name related_name
          action id
        ].map { |key| params[key] }.compact.join("/")
      end
    end
  end
end
