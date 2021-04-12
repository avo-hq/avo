require_dependency "avo/application_controller"

module Avo
  class HomeController < ApplicationController
    def index
      if Avo.configuration.home_path.present?
        redirect_to Avo.configuration.home_path
      elsif !Rails.env.development?
        @page_title = "Get started"
        redirect_to resources_path Avo::App.get_resources.min_by { |resource| resource.route_key }.model_class
      end
    end
  end
end
