module Avo
  module SummaryChartHelper
    # Single place that defines which request state must travel from the index view
    # to the summarizable distribution chart. Keeps the two in sync by construction —
    # adding a new filter mechanism only requires updating this helper, not the template.
    def summary_chart_params_for(field)
      # On association routes the route itself carries the parent identity (:resource_name/:id/:related_name),
      # so we derive via_* from params as a reliable fallback. The ivars `@parent_record` / `@parent_resource`
      # exist on full-page renders but are not always visible to re-rendered ViewComponent subtrees during
      # turbo-stream updates (e.g. X-Search-Request), which caused the chart to fall back to the global
      # query_scope and drift from the index view.
      via_record_id = @parent_record&.to_param || params[:id]
      via_resource_class = @parent_resource&.class&.to_s ||
        (params[:resource_name].present? ? Avo.resource_manager.get_resource_by_name(params[:resource_name])&.to_s : nil)

      summary_params = {
        resource_name: field.resource.model_class,
        field_id: field.id,
        via_record_id: via_record_id,
        via_resource_class: via_resource_class,
        association_name: @field&.attribute_id || params[:related_name],
        encoded_filters: @current_encoded_filters,
        scope: params[:scope],
        q: params[:q]
      }.compact

      if defined?(Avo::DynamicFilters)
        dynamic_key = Avo::DynamicFilters.configuration.param_key
        summary_params[dynamic_key] = params[dynamic_key] if params[dynamic_key].present?
      end

      summary_params
    end
  end
end
