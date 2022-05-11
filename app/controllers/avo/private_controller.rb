require_dependency "avo/application_controller"

module Avo
  class PrivateController < ApplicationController
    def design
      @page_title = "Design [Private]"
    end
  end
end
