module Avo
  module Concerns
    module RequestMethods
      def referrer_params
        @referrer_params ||= begin
          Rack::Utils.parse_query(URI(request.referrer).query)
        rescue ArgumentError => _e
          {}
        end
      end
    end
  end
end
