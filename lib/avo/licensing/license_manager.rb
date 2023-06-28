module Avo
  module Licensing
    class LicenseManager
      def initialize(hq_response)
        @hq_response = hq_response
      end

      def license
        case @hq_response["id"]
        when "community"
          CommunityLicense.new @hq_response
        when "pro"
          ProLicense.new @hq_response
        else
          NilLicense.new @hq_response
        end
      end

      def self.refresh_license(request)
        new(Licensing::HQ.new(request).fresh_response).license
      end
    end
  end
end
