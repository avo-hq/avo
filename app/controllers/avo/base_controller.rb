require_dependency "avo/application_controller"

module Avo
  class BaseController < ApplicationController
    before_action :set_resource_name
    before_action :set_resource
    before_action :hydrate_resource
    before_action :set_applied_filters, only: :index
    before_action :set_model, only: [:show, :edit, :destroy, :update, :order]
    before_action :set_model_to_fill
    before_action :set_edit_title_and_breadcrumbs, only: [:edit, :update]
    before_action :fill_model, only: [:create, :update]
    # Don't run base authorizations for associations
    before_action :authorize_base_action, if: -> { controller_name != "associations" }

    def index
      @page_title = @resource.plural_name.humanize
      add_breadcrumb @resource.plural_name.humanize

      set_index_params
      set_filters
      set_actions

      # If we don't get a query object predefined from a child controller like associations, just spin one up
      unless defined? @query
        @query = @resource.class.query_scope
      end

      # Remove default_scope for index view if no parent_resource present
      if @resource.unscoped_queries_on_index && @parent_resource.blank?
        @query = @query.unscoped
      end

      # Eager load the associations
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

        # Check if the sortable field option is actually a proc and we need to do a custom sort
        field_id = @index_params[:sort_by].to_sym
        field = @resource.get_field_definitions.find { |field| field.id == field_id }
        @query = if field&.sortable.is_a?(Proc)
          field.sortable.call(@query, @index_params[:sort_direction])
        else
          @query.order("#{@resource.model_class.table_name}.#{@index_params[:sort_by]} #{@index_params[:sort_direction]}")
        end
      end

      # Apply filters to the current query
      filters_to_be_applied.each do |filter_class, filter_value|
        @query = filter_class.safe_constantize.new.apply_query request, @query, filter_value
      end

      extra_pagy_params = {}

      # Reset open filters when a user navigates to a new page
      extra_pagy_params[:keep_filters_panel_open] = if params[:keep_filters_panel_open] == "1"
        "0"
      end

      @pagy, @models = pagy(@query, items: @index_params[:per_page], link_extra: "data-turbo-frame=\"#{params[:turbo_frame]}\"", size: [1, 2, 2, 1], params: extra_pagy_params)

      # Create resources for each model
      @resources = @models.map do |model|
        @resource.hydrate(model: model, params: params).dup
      end
    end

    def show
      @resource.hydrate(model: @model, view: :show, user: _current_user, params: params)

      set_actions

      @page_title = @resource.default_panel_name.to_s

      # If we're accessing this resource via another resource add the parent to the breadcrumbs.
      if params[:via_resource_class].present? && params[:via_resource_id].present?
        via_resource = Avo::App.get_resource_by_model_name params[:via_resource_class]
        via_model = via_resource.class.find_scope.find params[:via_resource_id]
        via_resource.hydrate model: via_model

        add_breadcrumb via_resource.plural_name, resources_path(resource: via_resource)
        add_breadcrumb via_resource.model_title, resource_path(model: via_model, resource: via_resource)
      else
        add_breadcrumb @resource.plural_name.humanize, resources_path(resource: @resource)
      end

      add_breadcrumb @resource.model_title
      add_breadcrumb I18n.t("avo.details").upcase_first
    end

    def new
      @model = @resource.model_class.new
      @resource = @resource.hydrate(model: @model, view: :new, user: _current_user)

      set_actions

      @page_title = @resource.default_panel_name.to_s

      if params[:via_relation_class].present? && params[:via_resource_id].present?
        via_resource = Avo::App.get_resource_by_model_name params[:via_relation_class]
        via_model = via_resource.class.find_scope.find params[:via_resource_id]
        via_resource.hydrate model: via_model

        add_breadcrumb via_resource.plural_name, resources_path(resource: via_resource)
        add_breadcrumb via_resource.model_title, resource_path(model: via_model, resource: via_resource)
      end

      add_breadcrumb @resource.plural_name.humanize, resources_path(resource: @resource)
      add_breadcrumb t("avo.new").humanize
    end

    def create
      # model gets instantiated and filled in the fill_model method
      saved = save_model
      @resource.hydrate(model: @model, view: :new, user: _current_user)

      # This means that the record has been created through another parent record and we need to attach it somehow.
      if params[:via_resource_id].present?
        @reflection = @model._reflections[params[:via_relation]]
        # Figure out what kind of association does the record have with the parent record

        # Fills in the required infor for belongs_to and has_many
        # Get the foreign key and set it to the id we received in the params
        if @reflection.is_a?(ActiveRecord::Reflection::BelongsToReflection) || @reflection.is_a?(ActiveRecord::Reflection::HasManyReflection)
          @model.send("#{@reflection.foreign_key}=", params[:via_resource_id])
          @model.save
        end

        # For when working with has_one, has_one_through, has_many_through, has_and_belongs_to_many, polymorphic
        if @reflection.is_a? ActiveRecord::Reflection::ThroughReflection
          # find the record
          via_resource = ::Avo::App.get_resource_by_model_name params[:via_relation_class]
          @related_record = via_resource.model_class.find params[:via_resource_id]

          @model.send(params[:via_relation]) << @related_record
        end
      end

      respond_to do |format|
        if saved
          format.html { redirect_to after_create_path, notice: "#{@resource.name} #{t("avo.was_successfully_created")}." }
        else
          add_breadcrumb @resource.plural_name.humanize, resources_path(resource: @resource)
          add_breadcrumb t("avo.new").humanize
          set_actions
          flash.now[:error] = t "avo.you_missed_something_check_form"
          format.html { render :new, status: :unprocessable_entity }
        end
      end
    end

    def edit
      set_actions
    end

    def update
      # model gets instantiated and filled in the fill_model method
      saved = save_model
      @resource = @resource.hydrate(model: @model, view: :edit, user: _current_user)

      respond_to do |format|
        if saved
          format.html { redirect_to after_update_path, notice: "#{@resource.name} #{t("avo.was_successfully_updated")}." }
        else
          set_actions
          flash.now[:error] = t "avo.you_missed_something_check_form"
          format.html { render :edit, status: :unprocessable_entity }
        end
      end
    end

    def destroy
      respond_to do |format|
        if destroy_model
          format.html { redirect_to params[:referrer] || resources_path(resource: @resource, turbo_frame: params[:turbo_frame], view_type: params[:view_type]), notice: t("avo.resource_destroyed", attachment_class: @attachment_class) }
        else
          error_message = @errors.present? ? @errors.first : t("avo.failed")

          format.html { redirect_back fallback_location: params[:referrer] || resources_path(resource: @resource, turbo_frame: params[:turbo_frame], view_type: params[:view_type]), error: error_message }
        end
      end
    end

    def order
      direction = params[:direction].to_sym

      if direction.present?
        @resource
          .hydrate(model: @model, params: params)
          .ordering_host
          .order direction
      end

      respond_to do |format|
        format.html { redirect_to params[:referrer] || resources_path(resource: @resource) }
      end
    end

    private

    def save_model
      perform_action_and_record_errors do
        @model.save!
      end
    end

    def destroy_model
      perform_action_and_record_errors do
        @model.destroy!
      end
    end

    def perform_action_and_record_errors(&block)
      begin
        succeeded = block.call
      rescue => exception
        # In case there's an error somewhere else than the model
        # Example: When you save a license that should create a user for it and creating that user throws and error.
        # Example: When you Try to delete a record and has a foreign key constraint.
        @errors = Array.wrap(exception.message)
      end

      succeeded
    end

    def model_params
      request_params = params.require(model_param_key).permit(permitted_params)

      if @resource.devise_password_optional && request_params[:password].blank? && request_params[:password_confirmation].blank?
        request_params.delete(:password_confirmation)
        request_params.delete(:password)
      end

      request_params
    end

    def permitted_params
      @resource.get_field_definitions.select(&:updatable).map(&:to_permitted_param).concat extra_params
    end

    def extra_params
      @resource.class.extra_params || []
    end

    def cast_nullable(params)
      fields = @resource.get_field_definitions

      nullable_fields = fields
        .filter do |field|
          field.nullable
        end
        .map do |field|
          [field.id, field.null_values]
        end
        .to_h

      params.each do |key, value|
        nullable_values = nullable_fields[key.to_sym]

        if nullable_values.present? && value.in?(nullable_values)
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
      @actions = @resource
        .get_actions
        .map do |action|
          action.new(model: @model, resource: @resource, view: @view)
        end
        .select do |action|
          action.visible_in_view
        end
    end

    def set_applied_filters
      @applied_filters = Avo::Filters::BaseFilter.decode_filters(params[Avo::Filters::BaseFilter::PARAM_KEY])

      # Some filters react to others and will have to be merged into this
      @applied_filters = @applied_filters.merge reactive_filters
    rescue
      @applied_filters = {}
    end

    def reactive_filters
      filter_reactions = {}

      # Go through all filters
      @resource.get_filters
        .select do |filter_class|
          filter_class.instance_methods(false).include? :react
        end
        .each do |filter_class|
          # Run the react method if it's present
          reaction = filter_class.new.react

          next if reaction.nil?

          filter_reactions[filter_class.to_s] = filter_class.new.react
        end

      filter_reactions
    end

    # Get the default state of the filters and override with the user applied filters
    def filters_to_be_applied
      filter_defaults = {}

      @resource.get_filters.each do |filter_class|
        filter = filter_class.new

        unless filter.default.nil?
          filter_defaults[filter_class.to_s] = filter.default
        end
      end

      filter_defaults.merge(@applied_filters)
    end

    def set_edit_title_and_breadcrumbs
      @resource = @resource.hydrate(model: @model, view: :edit, user: _current_user)
      @page_title = @resource.default_panel_name.to_s

      last_crumb_args = {}
      # If we're accessing this resource via another resource add the parent to the breadcrumbs.
      if params[:via_resource_class].present? && params[:via_resource_id].present?
        via_resource = Avo::App.get_resource_by_model_name params[:via_resource_class]
        via_model = via_resource.class.find_scope.find params[:via_resource_id]
        via_resource.hydrate model: via_model

        add_breadcrumb via_resource.plural_name, resources_path(resource: @resource)
        add_breadcrumb via_resource.model_title, resource_path(model: via_model, resource: via_resource)

        last_crumb_args = {
          via_resource_class: params[:via_resource_class],
          via_resource_id: params[:via_resource_id]
        }
      else
        add_breadcrumb @resource.plural_name.humanize, resources_path(resource: @resource)
      end

      add_breadcrumb @resource.model_title, resource_path(model: @resource.model, resource: @resource, **last_crumb_args)
      add_breadcrumb t("avo.edit").humanize
    end

    def after_create_path
      # If this is an associated record return to the association show page
      if params[:via_relation_class].present? && params[:via_resource_id].present?
        parent_resource = ::Avo::App.get_resource_by_model_name params[:via_relation_class].safe_constantize

        return resource_path(model: params[:via_relation_class].safe_constantize, resource: parent_resource, resource_id: params[:via_resource_id])
      end

      redirect_path_from_resource_option(:after_create_path) || resource_path(model: @model, resource: @resource)
    end

    def after_update_path
      return params[:referrer] if params[:referrer].present?

      redirect_path_from_resource_option(:after_update_path) || resource_path(model: @model, resource: @resource)
    end

    def redirect_path_from_resource_option(action = :after_update_path)
      return nil if @resource.class.send(action).blank?

      if @resource.class.send(action) == :index
        resources_path(resource: @resource)
      elsif @resource.class.send(action) == :edit
        edit_resource_path(resource: @resource, model: @resource.model)
      else
        resource_path(model: @model, resource: @resource)
      end
    end
  end
end
