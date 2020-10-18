require_dependency 'avo/application_controller'

module Avo
  class FiltersController < ApplicationController
    before_action :authorize_user

    def index
      avo_filters = avo_resource.get_filters
      filters = []

      avo_filters.each do |filter|
        filters.push(filter.new.render_response)
      end

      render json: {
        filters: filters,
      }
    end
  end
end
