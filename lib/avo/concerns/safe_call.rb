module Avo
  module Concerns
    module SafeCall
      def safe_call(method, **)
        send(method, **) if respond_to?(method, true)
      end
    end
  end
end
