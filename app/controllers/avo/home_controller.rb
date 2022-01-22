require_dependency "avo/application_controller"

module Avo
  class HomeController < ApplicationController
    def index
      if Avo.configuration.home_path.present?
        redirect_to Avo.configuration.home_path
      elsif !Rails.env.development?
        @page_title = "Get started"
        resource = Avo::App.resources.min_by { |resource| resource.model_key }
        redirect_to resources_path(resource: resource)
      end
    end

    def failed_to_load
    end
  end
end
