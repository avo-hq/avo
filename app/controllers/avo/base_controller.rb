require_dependency "avo/application_controller"

module Avo
  class BaseController < ApplicationController
    before_action :set_resource_name
    before_action :set_resource
    before_action :hydrate_resource
    before_action :set_model, only: [:show, :edit, :destroy, :update]
    before_action :set_model_to_fill
    before_action :fill_model, only: [:create, :update]
    before_action :authorize_action
    before_action :reset_pagination_if_filters_changed, only: :index
    before_action :cache_applied_filters, only: :index

    def index
      @page_title = resource_name.humanize
      add_breadcrumb resource_name.humanize

      set_index_params
      set_filters
      set_actions

      # If we don't get a query object predefined from a child controller like relations, just spin one up
      unless defined? @query
        @query = @resource.class.query_scope
      end

      # Remove default_scope for index view if no parent_resource present
      if @resource.unscoped_queries_on_index && @parent_resource.blank?
        @query = @query.unscoped
      end

      # Eager load the relations
      if @resource.includes.present?
        @query = @query.includes(*@resource.includes)
      end

      # Eager load the active storage attachments
      @query = eager_load_files(@resource, @query)

      # Sort the items
      if @index_params[:sort_by].present?
        unless @index_params[:sort_by].eql? :created_at
          @query = @query.unscope(:order)
        end
        @query = @query.order("#{@resource.model_class.table_name}.#{@index_params[:sort_by]} #{@index_params[:sort_direction]}")
      end

      # Apply filters
      applied_filters.each do |filter_class, filter_value|
        @query = filter_class.safe_constantize.new.apply_query request, @query, filter_value
      end

      @pagy, @models = pagy(@query, items: @index_params[:per_page], link_extra: "data-turbo-frame=\"#{params[:turbo_frame]}\"", size: [1, 2, 2, 1])

      # Create resources for each model
      @resources = @models.map do |model|
        @resource.hydrate(model: model, params: params).dup
      end
    end

    def show
      set_actions

      @resource = @resource.hydrate(model: @model, view: :show, user: _current_user, params: params)

      @page_title = @resource.default_panel_name

      # If we're accessing this resource via another resource add the parent to the breadcrumbs.
      if params[:via_resource_class].present? && params[:via_resource_id].present?
        via_resource = Avo::App.get_resource_by_model_name params[:via_resource_class]
        via_model = via_resource.class.find_scope.find params[:via_resource_id]
        via_resource.hydrate model: via_model

        add_breadcrumb via_resource.plural_name, resources_path(resource: via_resource)
        add_breadcrumb via_resource.model_title, resource_path(model: via_model, resource: via_resource)
      else
        add_breadcrumb resource_name.humanize, resources_path(resource: @resource)
      end

      add_breadcrumb @resource.model_title
    end

    def new
      @model = @resource.model_class.new
      @resource = @resource.hydrate(model: @model, view: :new, user: _current_user)
      # abort @model.course.inspect

      @page_title = @resource.default_panel_name
      add_breadcrumb resource_name.humanize, resources_path(resource: @resource)
      add_breadcrumb t("avo.new").humanize
    end

    def edit
      @resource = @resource.hydrate(model: @model, view: :edit, user: _current_user)

      @page_title = @resource.default_panel_name

      # If we're accessing this resource via another resource add the parent to the breadcrumbs.
      if params[:via_resource_class].present? && params[:via_resource_id].present?
        via_resource = Avo::App.get_resource_by_model_name params[:via_resource_class]
        via_model = via_resource.class.find_scope.find params[:via_resource_id]
        via_resource.hydrate model: via_model

        add_breadcrumb via_resource.plural_name, resources_path(resource: @resource)
        add_breadcrumb via_resource.model_title, resource_path(model: via_model, resource: via_resource)
      else
        add_breadcrumb resource_name.humanize, resources_path(resource: @resource)
      end

      add_breadcrumb @resource.model_title, resource_path(model: @resource.model, resource: @resource)
      add_breadcrumb t("avo.edit").humanize
    end

    def create
      # model gets instantiated and filled in the fill_model method
      saved = @model.save
      @resource.hydrate(model: @model, view: :new, user: _current_user)

      # This means that the record has been created through another parent record and we need to attach it somehow.
      if params[:via_resource_id].present?
        @reflection = @model._reflections[params[:via_relation]]
        # Figure out what kind of association does the record have with the parent record

        # belongs_to
        # has_many
        # Get the foreign key and set it to the id we received in the params
        if @reflection.is_a?(ActiveRecord::Reflection::BelongsToReflection) || @reflection.is_a?(ActiveRecord::Reflection::HasManyReflection)
          foreign_key = @reflection.foreign_key
          @model.send("#{foreign_key}=", params[:via_resource_id])
          @model.save
        end

        # has_one
        # has_one_through

        # has_many_through
        # has_and_belongs_to_many
        # polymorphic
        if @reflection.is_a? ActiveRecord::Reflection::ThroughReflection
          # find the record
          via_resource = ::Avo::App.get_resource_by_model_name params[:via_relation_class]
          @related_record = via_resource.model_class.find params[:via_resource_id]

          @model.send(params[:via_relation]) << @related_record
        end
      end

      respond_to do |format|
        if saved
          redirect_path = resource_path(model: @model, resource: @resource)

          if params[:via_relation_class].present? && params[:via_resource_id].present?
            parent_resource = ::Avo::App.get_resource_by_model_name params[:via_relation_class].safe_constantize
            redirect_path = resource_path(model: params[:via_relation_class].safe_constantize, resource: parent_resource, resource_id: params[:via_resource_id])
          end

          format.html { redirect_to redirect_path, notice: "#{@model.class.name} #{t("avo.was_successfully_created")}." }
          format.json { render :show, status: :created, location: @model }
        else
          flash[:error] = t "avo.you_missed_something_check_form"
          format.html { render :new, status: :unprocessable_entity }
          format.json { render json: @model.errors, status: :unprocessable_entity }
        end
      end
    end

    def update
      # model gets instantiated and filled in the fill_model method
      saved = @model.save
      @resource = @resource.hydrate(model: @model, view: :edit, user: _current_user)

      respond_to do |format|
        if saved
          format.html { redirect_to params[:referrer] || resource_path(model: @model, resource: @resource), notice: "#{@model.class.name} #{t("avo.was_successfully_updated")}." }
          format.json { render :show, status: :ok, location: @model }
        else
          flash[:error] = t "avo.you_missed_something_check_form"
          format.html { render :edit, status: :unprocessable_entity }
          format.json { render json: @model.errors, status: :unprocessable_entity }
        end
      end
    end

    def destroy
      @model.destroy!

      respond_to do |format|
        format.html { redirect_to params[:referrer] || resources_path(resource: @resource, turbo_frame: params[:turbo_frame], view_type: params[:view_type]), notice: t("avo.resource_destroyed", attachment_class: @attachment_class) }
        format.json { head :no_content }
      end
    end

    private

    def model_params
      request_params = params.require(model_param_key).permit(permitted_params)

      if @resource.devise_password_optional && request_params[:password].blank? && request_params[:password_confirmation].blank?
        request_params.delete(:password_confirmation)
        request_params.delete(:password)
      end

      request_params
    end

    def permitted_params
      @resource.get_field_definitions.select(&:updatable).map(&:to_permitted_param)
    end

    def cast_nullable(params)
      fields = @resource.get_field_definitions

      nullable_fields = fields.filter do |field|
        field.nullable
      end
        .map do |field|
        [field.id, field.null_values]
      end
        .to_h

      params.each do |key, value|
        nullable = nullable_fields[key.to_sym]

        if nullable.present? && value.in?(nullable)
          params[key] = nil
        end
      end

      params
    end

    def set_index_params
      @index_params = {}

      # Pagination
      @index_params[:page] = params[:page] || 1
      @index_params[:per_page] = Avo.configuration.per_page

      if cookies[:per_page].present?
        @index_params[:per_page] = cookies[:per_page]
      end

      if @parent_model.present?
        @index_params[:per_page] = Avo.configuration.via_per_page
      end

      if params[:per_page].present?
        @index_params[:per_page] = params[:per_page]
        cookies[:per_page] = params[:per_page]
      end

      # Sorting
      if params[:sort_by].present?
        @index_params[:sort_by] = params[:sort_by]
      elsif @resource.model_class.present? && @resource.model_class.column_names.include?("created_at")
        @index_params[:sort_by] = :created_at
      end

      @index_params[:sort_direction] = params[:sort_direction] || :desc

      # View types
      @index_params[:view_type] = params[:view_type] || @resource.default_view_type || Avo.configuration.default_view_type
      @index_params[:available_view_types] = @resource.available_view_types
    end

    def set_filters
      @filters = @resource.get_filters.map do |filter_class|
        filter = filter_class.new

        filter
      end
    end

    def set_actions
      if params[:resource_id].present?
        model = @resource.class.find_scope.find params[:resource_id]
      end

      @actions =
        @resource
          .get_actions
          .map do |action|
            action.new(model: model, resource: @resource, view: @view)
          end
          .select { |action| action.visible_in_view }
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

    def cache_applied_filters
      ::Avo::App.cache_store.delete applied_filters_cache_key if params[:filters].nil?

      ::Avo::App.cache_store.write(applied_filters_cache_key, params[:filters], expires_in: 7.days)
    end

    def reset_pagination_if_filters_changed
      params[:page] = 1 if params[:filters] != ::Avo::App.cache_store.read(applied_filters_cache_key)
    end

    def applied_filters_cache_key
      "avo.base_controller.#{@resource.model_key}.applied_filters"
    end
  end
end
