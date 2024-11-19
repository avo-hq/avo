require_dependency "avo/base_controller"

module Avo
  class ChartsController < BaseController
    def distribution_chart
      @values_summary = scoped_query.group(params[:field_id].to_sym).reorder("count_all desc").count

      @field_id = params[:field_id]

      render "avo/partials/distribution_chart", layout: "avo/blank"
    end

    private

    def scoped_query
      if is_associated_record?
        query = resource.authorization&.apply_policy related_records

        Avo::ExecutionContext.new(target: resource.search_query, query: query).handle
      else
        resource.query_scope
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
