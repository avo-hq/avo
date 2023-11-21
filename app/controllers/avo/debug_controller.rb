require_dependency "avo/application_controller"

module Avo
  class DebugController < ApplicationController
    def status
    end

    def send_to_hq
      url = "#{ENV["HQ_URL"]}/api/v3/debug_requests"
      timeout = 10 # seconds
      license_key = Avo::Services::DebugService.debug_report(request)[:hq_payload][:license_key]
      body = params[:body]
      body = {license_key: license_key, body: body, payload: Avo::Services::DebugService.debug_report(request).to_json}.to_json

      HTTParty.post url, body: body, headers: {"Content-Type": "application/json"}, timeout: timeout

      render turbo_stream: turbo_stream.replace(:send_to_hq, plain: "Payload sent to Avo HQ.")
    end

    def report
    end

    def refresh_license
      license = Licensing::LicenseManager.refresh_license request

      if license.valid?
        flash[:notice] = "avohq.io responded: \"#{license.id.humanize} license is valid\"."
      elsif license.response["reason"].present?
        flash[:error] = "avohq.io responded: \"#{license.response["reason"]}\"."
      else
        flash[:error] = license.response["error"]
      end

      redirect_back fallback_location: avo.avo_private_status_path
    end
  end
end
