require_dependency 'avo/application_controller'

module Avo
  class ResourcesController < ApplicationController
    before_action :set_resource_name
    before_action :set_resource
    before_action :set_model, only: [:show, :edit, :destroy, :update]
    before_action :set_per_page, only: :index
    before_action :set_filters, only: :index
    before_action :set_actions, only: [:index, :show]

    def index
      @heading = @resource.plural_name

      params[:page] ||= 1
      params[:sort_by] = params[:sort_by].present? ? params[:sort_by] : :created_at
      params[:sort_direction] = params[:sort_direction].present? ? params[:sort_direction] : :desc

      # @todo: remove this
      @authorization.set_record(@resource.model_class).authorize_action :index
      query = AuthorizationService.with_policy _current_user, @resource.model_class

      if params[:sort_by]
        query = query.order("#{params[:sort_by]} #{params[:sort_direction]}")
      end

      applied_filters.each do |filter_class, filter_value|
        query = filter_class.safe_constantize.new.apply_query request, query, filter_value
      end

      @resource.hydrate(view: :index, user: _current_user)
      @models = query.page(params[:page]).per(@per_page)
      @resources = @models.map do |model|
        @resource.hydrate(model: model).dup
      end
    end

    def show
      @resource = @resource.hydrate(model: @model, view: :show, user: _current_user)
      @authorization.set_record(@model).authorize_action :show
    end

    def new
      @model = @resource.model_class.new
      @authorization.set_record(@model).authorize_action :new
      @resource = @resource.hydrate(model: @model, view: :new, user: _current_user)
    end

    def edit
      @authorization.set_record(@model).authorize_action :edit
      @resource = @resource.hydrate(model: @model, view: :edit, user: _current_user)
    end

    def create
      @model = @resource.model_class.new(model_params)
      @authorization.set_record(@model).authorize_action :create

      respond_to do |format|
        if @model.save
          format.html { redirect_to resource_path(@model), notice: "#{@model.class.name} was successfully created." }
          format.json { render :show, status: :created, location: @model }
        else
          @resource = @resource.hydrate(model: @model, view: :new, user: _current_user)
          format.html { render :new, status: :unprocessable_entity }
          format.json { render json: @model.errors, status: :unprocessable_entity }
        end
      end
    end

    def update
      @authorization.set_record(@model).authorize_action :update
      respond_to do |format|
        if @model.update(cast_nullable(model_params))
          format.html { redirect_to resource_path(@model), notice: "#{@model.class.name} was successfully updated." }
          format.json { render :show, status: :ok, location: @post }
        else
          @resource = @resource.hydrate(model: @model, view: :edit, user: _current_user)
          format.html { render :edit, status: :unprocessable_entity }
          format.json { render json: @post.errors, status: :unprocessable_entity }
        end
      end
    end

    def destroy
      @authorization.set_record(@model).authorize_action :destroy
      @model.destroy!

      respond_to do |format|
        format.html { redirect_to resources_path(@model), notice: "#{@model.class.name} was successfully destroyed." }
        format.json { head :no_content }
      end
    end

    private
      def model_params
        params.require(@resource.model_class.model_name.route_key.singularize).permit(permitted_params)
      end

      def permitted_params
        permitted = @resource.get_field_definitions.select(&:updatable).map do |field|
          # If it's a relation
          if field.methods.include? :foreign_key
            database_id = field.foreign_key
          end

          if database_id.present?
            # Allow the database_id for belongs_to relation
            database_id.to_sym
          elsif field.is_array_param
            # Allow array param if necessary
            { "#{field.id}": [] }
          elsif field.is_object_param
            # Allow array param if necessary
            [:"#{field.id}", "#{field.id}": {} ]
          else
            field.id.to_sym
          end
        end

        permitted
      end

      def set_per_page
        @per_page = Avo.configuration.per_page

        if cookies[:per_page].present?
          @per_page = cookies[:per_page]
        end

        if params[:per_page].present?
          @per_page = params[:per_page]
        end

        if params[:per_page].present?
          cookies[:per_page] = params[:per_page]
        end
      end

      def set_filters
        @filters = @resource.get_filters.map(&:new)
      end

      def set_actions
        if params[:resource_id].present?
          model = @resource.model_class.find params[:resource_id]
        end

        @actions = @resource.get_actions.map do |action|
          action = action.new

          action.set_model model
          action.set_resource @resource
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
  end
end
