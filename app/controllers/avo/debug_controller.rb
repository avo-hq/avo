require_dependency "avo/application_controller"

module Avo
  class DebugController < ApplicationController
    def index
    end

    def report
    end

    def refresh_license
      license = Licensing::LicenseManager.refresh_license request

      if license.valid?
        flash[:notice] = "avohq.io responded: \"#{license.id.humanize} license is valid\"."
      else
        if license.response['reason'].present?
          flash[:error] = "avohq.io responded: \"#{license.response['reason']}\"."
        else
          flash[:error] = license.response['error']
        end
      end

      redirect_back fallback_location: avo.avo_private_debug_index_path
    end
  end
end
