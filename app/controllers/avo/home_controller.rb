require_dependency "avo/application_controller"

module Avo
  class HomeController < ApplicationController
    def index
      if Avo.configuration.home_path.present?
        # If the home_path is a block run it, if not, just use it
        computed_path = if Avo.configuration.home_path.respond_to? :call
          instance_exec(&Avo.configuration.home_path)
        else
          Avo.configuration.home_path
        end

        redirect_to computed_path
      elsif !Rails.env.development?
        @page_title = "Get started"
        resource = Avo.resource_manager.all.min_by { |resource| resource.model_key }
        redirect_to resources_path(resource: resource)
      end
    end

    def failed_to_load
    end
  end
end
