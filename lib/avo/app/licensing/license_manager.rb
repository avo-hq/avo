require_relative 'license'
require_relative 'community_license'
require_relative 'pro_license'
require_relative 'null_license'
require_relative 'hq'

module Avo
  class LicenseManager
    attr_accessor :home

    def initialize(current_request)
      @home = HQ.new current_request
    end

    def valid?
      license.valid?
    end

    def license
      response = @home.response

      case response['id']
      when 'community'
        CommunityLicense.new response
      when 'pro'
        ProLicense.new response
      else
        NullLicense.new response
      end
    end
  end
end
