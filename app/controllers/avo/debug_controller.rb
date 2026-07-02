require_dependency "avo/application_controller"

module Avo
  class DebugController < ApplicationController
    before_action :authenticate_developer_or_admin!

    def status
      respond_to do |format|
        format.html { render :status }
        format.text { render :status }
      end
    end
  end
end
