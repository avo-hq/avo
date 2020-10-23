require_relative 'license'
require_relative 'home'

module Avo
  class LicenseManager
    attr_accessor :home

    def initialize(current_request)
      @home = Home.new current_request
    end

    def valid?
      license.valid?
    end

    def license
      response = @home.response

      case response[:id]
      when 'solo'
        SoloLicense.new response
      when 'pro'
        ProLicense.new response
      else
        NullLicense.new
      end
    end
  end
end
