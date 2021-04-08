require_dependency "avo/application_controller"

module Avo
  class HomeController < ApplicationController
    def index
      @page_title = "Get started"

      if Avo.configuration.home_path.present?
        redirect_to Avo.configuration.home_path
      elsif !Rails.env.development?
        redirect_to resources_path Avo::App.get_resources.min_by { |resource| resource.route_key }.model_class
      end
    end
  end
end
