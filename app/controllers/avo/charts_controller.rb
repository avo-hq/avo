require_dependency "avo/base_controller"

module Avo
  class ChartsController < BaseController
    def distribution_chart
      @values_summary = resource.model_class.group(params[:field_id]).reorder("count_all desc").count
      @field_id = params[:field_id]

      render "avo/partials/distribution_chart", layout: "avo/blank"
    end
  end
end
