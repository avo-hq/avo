require_dependency "avo/application_controller"

module Avo
  class BaseController < ApplicationController
    before_action :set_resource_name
    before_action :set_resource
    before_action :set_index_params, only: :index

    # Set the view component for the current view
    # It will try to use the custom component if it's set, otherwise it will use the default one
    def set_component_for(view, fallback_view: nil)
      # Fetch the components from the resource
      components = Avo::ExecutionContext.new(
        target: @resource.components,
        resource: @resource,
        record: @record,
        view: @view
      ).handle

      # If the component is not set, use the default one
      if (custom_component = components.dig("resource_#{view}_component".to_sym)).nil?
        return @component = "Avo::Views::Resources::#{@resource.type.to_s.camelize}::#{(fallback_view || view).to_s.classify}".constantize
      end

      # If the component is set, try to use it
      @component = custom_component.to_s.safe_constantize

      # If the component is not found, raise an error
      if @component.nil?
        raise "The component '#{custom_component}' was not found.\n" \
        "That component was fetched from 'self.components' option inside '#{@resource.class}' resource."
      end
    end

    def set_index_params
      @index_params = {}

      # Pagination
      @index_params[:page] = params[:page] || 1
      @index_params[:per_page] = Avo.configuration.per_page

      if cookies[:per_page].present?
        @index_params[:per_page] = cookies[:per_page]
      end

      if @parent_record.present?
        @index_params[:per_page] = Avo.configuration.via_per_page
      end

      if params[:per_page].present?
        @index_params[:per_page] = params[:per_page]
        cookies[:per_page] = params[:per_page]
      end

      # Sorting
      if params[:sort_by].present?
        @index_params[:sort_by] = params[:sort_by]
      elsif @resource.is_active_record_resource? && @resource.model_class.present? && @resource.model_class.column_names.include?("created_at")
        @index_params[:sort_by] = :created_at
      end

      @index_params[:sort_direction] = params[:sort_direction] || :desc

      # View types
      available_view_types = @resource.available_view_types
      @index_params[:available_view_types] = available_view_types

      @index_params[:view_type] = if params[:view_type].present?
        params[:view_type]
      elsif available_view_types.size == 1
        available_view_types.first
      else
        @resource.default_view_type || Avo.configuration.default_view_type
      end

      if available_view_types.exclude? @index_params[:view_type].to_sym
        raise "View type '#{@index_params[:view_type]}' is unavailable for #{@resource.class}."
      end
    end
  end
end
