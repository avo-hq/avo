module Avo
  module Concerns
    module SafeCall
      def safe_call(method, **kwargs)
        send(method, **kwargs) if respond_to?(method, true)
      end
    end
  end
end
