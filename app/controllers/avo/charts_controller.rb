require_dependency "avo/base_controller"

module Avo
  class ChartsController < BaseController
    def distribution_chart
      @values_summary = summary_query.group(params[:field_id].to_sym).reorder("count_all desc").count
        .transform_keys do |key|
        key = if key.is_a?(ActiveRecord::Base)
          res = Avo.resource_manager.get_resource_by_model_class(key.class)
          res ? res.new(record: key).record_title : (key.try(:name) || key.to_param)
        else
          key
        end

        key.presence || "—"
      end

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
      set_applied_filters
      set_index_params
      @query = is_associated_summary ? association_scope : resource.query_scope
      build_index_query
    end

    def association_scope
      parent_resource_class = Avo.resource_manager.get_resource(params[:via_resource_class])
      @parent_record = parent_resource_class.find_record(params[:via_record_id], params: params)
      @parent_resource = parent_resource_class.new(
        record: @parent_record,
        # Explicitly hardcoding the view to 'show' as association summaries are processed solely within this context
        view: Avo::ViewInquirer.new("show")
      )
      @parent_resource.detect_fields

      association_query_scope(
        parent_resource: @parent_resource,
        parent_record: @parent_record,
        association_name: params[:association_name],
        authorization: @resource.authorization(user: _current_user),
        resource: @resource
      )
    end
  end
end
