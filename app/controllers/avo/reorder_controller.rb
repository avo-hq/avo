require_dependency "avo/application_controller"

module Avo
  class ReorderController < ApplicationController
    before_action :set_resource_name
    before_action :set_resource
    before_action :hydrate_resource
    before_action :set_model

    def order
      direction = params[:direction].to_sym

      if direction.present?
        @resource
          .hydrate(model: @model, params: params)
          .ordering_host
          .order direction
      end

      respond_to do |format|
        format.html { redirect_to params[:referrer] || resources_path(resource: @resource) }
      end
    end
  end
end
