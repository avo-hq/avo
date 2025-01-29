module Avo
  module MediaLibrary
    class Configuration
      include ActiveSupport::Configurable

      config_accessor(:visible) { true }

      def visible?
        Avo::ExecutionContext.new(target: config[:visible]).handle
      end
    end

    def self.configuration
      @configuration ||= Configuration.new
    end

    def self.configure
      yield configuration
    end
  end
end
