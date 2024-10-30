require_dependency "avo/application_controller"

module Avo
  class PrivateController < ApplicationController
    before_action :authenticate_developer_or_admin!

    def design
      @page_title = "Design [Private]"
    end
  end
end
