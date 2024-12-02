require_dependency "avo/base_controller"

module Avo
  class ChartsController < BaseController
    def distribution_chart
      @values_summary = summary_query.group(params[:field_id].to_sym).reorder("count_all desc").count

      @field_id = params[:field_id]

      render "avo/partials/distribution_chart", layout: "avo/blank"
    end

    private

    def is_associated_summary
      params[:via_record_id].present? &&
      params[:via_resource_class].present? &&
      params[:association_name].present?
    end

    def summary_query
      is_associated_summary ? association_scope : resource.query_scope
    end

    def association_scope
      parent_resource_class = Avo.resource_manager.get_resource(params[:via_resource_class])
      parent_record = parent_resource_class.find_record(params[:via_record_id], params: params)

      parent_resource = parent_resource_class.new(
        record: parent_record,
        # Explicitly hardcoding the view to 'show' as association summaries are processed solely within this context
        view: Avo::ViewInquirer.new("show")
      )

      parent_resource.detect_fields

      association_name = BaseResource.valid_association_name(parent_record, params[:association_name])

      parent_field = find_association_field(resource: parent_resource, association: association_name)

      association_query = parent_resource.authorization.apply_policy parent_record.send(association_name)

      if parent_field.scope.present?
        association_query = Avo::ExecutionContext.new(
          target: parent_field.scope,
          query: association_query,
          parent: parent_record,
          parent_resource: parent_resource
        ).handle
      end

      association_query
    end
  end
end
