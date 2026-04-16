require_dependency "avo/base_controller"

module Avo
  class ChartsController < BaseController
    def distribution_chart
      compute_summary_data

      render "avo/partials/distribution_chart", layout: "avo/blank"
    end

    def distribution_chart_full
      compute_summary_data

      @page_title = "#{@resource.plural_name.humanize} — #{@field_id.to_s.humanize} summary"

      index_params = {
        encoded_filters: params[:encoded_filters],
        scope: params[:scope],
        q: params[:q]
      }
      if defined?(Avo::DynamicFilters)
        dynamic_filters_key = Avo::DynamicFilters.configuration.param_key
        index_params[dynamic_filters_key] = params[dynamic_filters_key]&.to_unsafe_h
      end
      index_params.compact!

      @back_path = if associated_summary?
        resource_path(record: @parent_record, resource: @parent_resource)
      else
        resources_path(resource: @resource, **index_params)
      end

      add_via_breadcrumbs
      add_breadcrumb title: "#{@field_id.to_s.humanize} summary"

      render "avo/partials/distribution_chart_full"
    end

    private

    def compute_summary_data
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
    end

    # The distribution chart runs the SAME pipeline as the regular index view:
    # starting relation → search → sort → standard filters → scopes → dynamic filters.
    # This is why filters, scopes, search, and dynamic filters stay in sync between
    # the table and the summary popover.
    def summary_query
      set_applied_filters
      set_index_params
      @query = base_index_query
      build_index_query
    end
  end
end
