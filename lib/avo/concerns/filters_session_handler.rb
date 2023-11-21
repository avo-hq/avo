module Avo
  module Concerns
    module FiltersSessionHandler
      def reset_filters
        return unless cache_resource_filters?

        session.delete(filters_session_key)
      end

      def fetch_filters
        return filters_from_params unless cache_resource_filters?

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
        @filters_session_key ||= "/filters/" << %w[
          turbo_frame controller resource_name related_name
          action id
        ].map { |key| params[key] }.compact.join("/")
      end

      def cache_resource_filters?
        Avo::ExecutionContext.new(
          target: Avo.configuration.cache_resource_filters,
          current_user: _current_user,
          resource: @resource
        ).handle
      end
    end
  end
end
