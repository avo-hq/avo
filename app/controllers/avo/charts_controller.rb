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

    # The distribution chart runs the SAME pipeline as the regular index view:
    # starting relation → search → sort → standard filters → scopes → dynamic filters.
    # This is why filters, scopes, search, and dynamic filters stay in sync between
    # the table and the summary popover.
    def summary_query
      set_applied_filters
      set_index_params
      set_query
      build_index_query
    end

    def set_query
      return super unless association_summary?

      @query ||= build_association_scope_from_params(
        resource: @resource,
        authorization: @resource.authorization(user: _current_user)
      )
    end
  end
end
