module Avo
  module MediaLibrary
    class Configuration
      include ActiveSupport::Configurable

      config_accessor(:visible) { true }
      config_accessor(:enabled) { false }

      def visible?
        return false if disabled?

        Avo::ExecutionContext.new(target: config[:visible]).handle
      end

      def enabled?
        Avo::ExecutionContext.new(target: config[:enabled]).handle
      end

      def disabled? = !enabled?
    end

    def self.configuration
      @configuration ||= Configuration.new
    end

    def self.configure
      yield configuration
    end
  end
end
