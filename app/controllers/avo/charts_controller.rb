module Avo
  class ChartsController < Avo::BaseController
    before_action :validate_summarizable_field

    def distribution_chart
      compute_summary_data

      render "avo/partials/distribution_chart", layout: "avo/blank"
    end

    def distribution_chart_full
      compute_summary_data

      @page_title = "#{@resource.plural_name} — #{@field_id.to_s.humanize} summary"
      @container_size = :md

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

    # Summarizable charts reuse the index query pipeline, so they ask the index policy, or on an
    # association page the parent's `view_<association>?`, which the association scope asks. They were
    # never meant to require `distribution_chart?` / `distribution_chart_full?` policy methods — those
    # only surfaced once `explicit_authorization` defaulted to true.
    def authorize_base_action
      authorize_action @resource.model_class, :index unless associated_summary?
    end

    # Field IDs aren't unique (forms vs. index variants), so match on summarizable too.
    def validate_summarizable_field
      @field = @resource.get_field_definitions.find do |f|
        f.id.to_s == params[:field_id].to_s && f.summarizable
      end
      head :not_found and return unless @field
    end

    def compute_summary_data
      # Different values can share a label (NULL and "", two records with one title). Their counts add up,
      # which can move the label away from where the query's order put it.
      @values_summary = summary_query.group(params[:field_id].to_sym).reorder("count_all desc").count
        .each_with_object(Hash.new(0)) { |(value, count), summary| summary[summary_label(value)] += count }
        .sort_by { |_label, count| -count }
        .to_h

      @field_id = params[:field_id]
    end

    def summary_label(value)
      label = if value.is_a?(ActiveRecord::Base)
        res = Avo.resource_manager.get_resource_by_model_class(value.class)
        res ? res.new(record: value).record_title : (value.try(:name) || value.to_param)
      else
        value
      end

      (label.nil? || label == "") ? "—" : label
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
