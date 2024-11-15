require_dependency "avo/base_controller"

module Avo
  class ChartsController < BaseController
    def distribution_chart
      @values_summary = records.group(params[:field_id]).reorder("count_all desc").count

      @field_id = params[:field_id]

      render "avo/partials/distribution_chart", layout: "avo/blank"
    end

    private

    def records
      if is_associated_record?
        related_records
      else
        resource.model_class
      end
    end

    def related_records
      relation_class = BaseResource.get_model_by_name(params[:via_relation_class])
      parent = relation_class.find(params[:via_record_id])

      association_name = BaseResource.valid_association_name(parent, resource.model_key)

      parent.send(association_name)
    end
  end
end
