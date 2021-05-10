require_dependency "avo/application_controller"

module Avo
  class SegmentsController < BaseController
    before_action :set_resource_name
    before_action :set_resource
    before_action :hydrate_resource
    before_action :authorize_action
    before_action :set_segment
    # before_action :set_model, only: [:show, :edit, :destroy, :update]
    # before_action :set_resource_name
    # before_action :set_resource

    def index
      @query = @authorization.apply_policy @resource.model_class
      @query = @segment.class.query.call(query: @query, params: params)

      super

      @page_title = @segment.name
      add_breadcrumb @segment.name

      @fields = @segment.get_fields
    end

    private

    def set_segment
      segment_class = params[:segment_id].camelize.safe_constantize
      # abort resource.inspect

      @segment = segment_class.new(resource: resource)
    end
  end
end
