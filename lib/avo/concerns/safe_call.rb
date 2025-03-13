module Avo
  module Concerns
    module SafeCall
      # rubocop:disable Style/ArgumentsForwarding
      def safe_call(method, **kwargs)
        send(method, **kwargs) if respond_to?(method, true)
      end
      # rubocop:enable Style/ArgumentsForwarding
    end
  end
end
