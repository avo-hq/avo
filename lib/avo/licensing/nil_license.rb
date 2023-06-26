module Avo
  module Licensing
    class NilLicense < License
      def initialize(response = nil)
        response ||= {
          id: Rails.env.test? ? "pro" : "community",
          valid: true
        }

        super(response)
      end
    end
  end
end
