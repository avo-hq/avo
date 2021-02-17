require_dependency 'avo/application_controller'

module Avo
  class BaseController < ApplicationController
    before_action :set_resource_name
    before_action :set_resource
    before_action :hydrate_resource
    before_action :authorize_action
    before_action :set_model, only: [:show, :edit, :destroy, :update]
    # before_action :set_filters, only: :index
    # before_action :set_actions, only: [:index, :show]
    # before_action :set_index_params, only: :index

    def index
      set_index_params
      set_filters
      set_actions

      # If we don't get a query object predefined from a child controller like relations, just spin one up
      unless defined? @query
        @query = @authorization.apply_policy @resource.model_class
      end

      # Eager load the relations
      if @resource.includes.present?
        @query = @query.includes(*@resource.includes)
      end

      # Sort the items
      if @index_params[:sort_by].present?
        @query = @query.order("#{@index_params[:sort_by]} #{@index_params[:sort_direction]}")
      end

      # Apply filters
      applied_filters.each do |filter_class, filter_value|
        @query = filter_class.safe_constantize.new.apply_query request, @query, filter_value
      end

      @pagy, @models = pagy(@query, items: @index_params[:per_page], link_extra: "data-turbo-frame=\"#{params[:frame_name]}\"")

      # Create resources for each model
      @resources = @models.map do |model|
        @resource.hydrate(model: model, params: params).dup
      end

      # Create a ResourceIndexComponent instance
      @component = Avo::ResourceIndexComponent.new(
        resource: @resource,
        resources: @resources,
        models: @models,
        pagy: @pagy,
        index_params: @index_params,
        filters: @filters,
        reflection: @reflection,
        frame_name: params[:frame_name],
        parent_resource: @parent_resource,
        parent_model: @parent_model
      )
    end

    def show
      set_actions

      @resource = @resource.hydrate(model: @model, view: :show, user: _current_user, params: params)
      @component = Avo::ResourceShowComponent.new(resource: @resource)
    end

    private
      def set_index_params
        @index_params = {}

        # Pagination
        @index_params[:page] = params[:page] || 1
        @index_params[:per_page] = Avo.configuration.per_page
        # if cookies[:per_page].present?
        #   @index_params[:per_page] = cookies[:per_page]
        # end

        if params[:per_page].present?
          @index_params[:per_page] = params[:per_page]
        end

        if params[:per_page].present?
          # cookies[:per_page] = params[:per_page]
        end

        # @index_params[:per_page] = 4

        # Sorting
        @index_params[:sort_by] = params[:sort_by] || :created_at
        @index_params[:sort_direction] = params[:sort_direction] || :desc

        # View types
        # abort @resource.inspect
        @index_params[:view_type] = params[:view_type] || @resource.default_view_type || Avo.configuration.default_view_type
        # abort @index_params[:view_type].inspect
        @index_params[:available_view_types] = @resource.available_view_types
      end

      def set_filters
        @filters = @resource.get_filters.map(&:new)
      end

      def set_actions
        # @todo: if the controller is relations, then replace the @resource with the @related_resource before this call
        # abort @resource.inspect
        if params[:resource_id].present?
          model = @resource.model_class.find params[:resource_id]
        end

        @actions = @resource.get_actions.map do |action|
          action = action.new

          action.hydrate(model: model, resource: @resource)
          action.boot_fields request

          action
        end
      end

      def applied_filters
        if params[:filters].present?
          return JSON.parse(Base64.decode64(params[:filters]))
        end

        filter_defaults = {}

        @resource.get_filters.each do |filter_class|
          filter = filter_class.new

          if filter.default.present?
            filter_defaults[filter_class.to_s] = filter.default
          end
        end

        filter_defaults
      end
  end
end
