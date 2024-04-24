require_dependency "avo/application_controller"

module Avo
  class SearchController < ApplicationController
    include Rails.application.routes.url_helpers

    before_action :set_resource_name, only: :show
    before_action :set_resource, only: :show

    def show
      render json: Avo::Services::SearchService.new(params:, authorization: @authorization).search_resources([resource])
    rescue => error
      render_search_error(error)
    end

    private

    def render_search_error(error)
      raise error unless Rails.env.development?

      render json: {
        error: {
          header: "🚨 An error occurred while searching. 🚨",
          help: "Please see the error and fix it before deploying.",
          results: {
            _label: error.message
          },
          count: 1
        }
      }, status: 500
    end
  end
end
