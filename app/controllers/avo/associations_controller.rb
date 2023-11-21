require_dependency "avo/base_controller"

module Avo
  class AssociationsController < BaseController
    before_action :set_record, only: [:show, :index, :new, :create, :destroy]
    before_action :set_related_resource_name
    before_action :set_related_resource, only: [:show, :index, :new, :create, :destroy]
    before_action :set_related_authorization
    before_action :set_reflection_field
    before_action :set_related_record, only: [:show]
    before_action :set_reflection
    before_action :set_attachment_class, only: [:show, :index, :new, :create, :destroy]
    before_action :set_attachment_resource, only: [:show, :index, :new, :create, :destroy]
    before_action :set_attachment_record, only: [:create, :destroy]
    before_action :authorize_index_action, only: :index
    before_action :authorize_attach_action, only: :new
    before_action :authorize_detach_action, only: :destroy

    def index
      @parent_resource = @resource.dup
      @resource = @related_resource
      @parent_record = @parent_resource.find_record(params[:id], params: params)
      @parent_resource.hydrate(record: @parent_record)
      association_name = BaseResource.valid_association_name(@parent_record, params[:related_name])
      @query = @related_authorization.apply_policy @parent_record.send(association_name)
      @association_field = @parent_resource.get_field params[:related_name]

      if @association_field.present? && @association_field.scope.present?
        @query = Avo::ExecutionContext.new(target: @association_field.scope, query: @query, parent: @parent_record).handle
      end

      super
    end

    def show
      @parent_resource, @parent_record = @resource, @record

      @resource, @record = @related_resource, @related_record

      super
    end

    def new
      @resource.hydrate(record: @record)

      if @field.present? && !@field.is_searchable?
        query = @related_authorization.apply_policy @attachment_class

        # Add the association scope to the query scope
        if @field.attach_scope.present?
          query = Avo::ExecutionContext.new(target: @field.attach_scope, query: query, parent: @record).handle
        end

        @options = query.all.map do |record|
          [@attachment_resource.new(record: record).record_title, record.id]
        end
      end
    end

    def create
      association_name = BaseResource.valid_association_name(@record, params[:related_name])

      if reflection_class == "HasManyReflection"
        @record.send(association_name) << @attachment_record
      else
        @record.send("#{association_name}=", @attachment_record)
      end

      respond_to do |format|
        if @record.save
          format.html { redirect_back fallback_location: resource_view_response_path, notice: t("avo.attachment_class_attached", attachment_class: @related_resource.name) }
        else
          format.html { render :new }
        end
      end
    end

    def destroy
      association_name = BaseResource.valid_association_name(@record, params[:related_name])

      if reflection_class == "HasManyReflection"
        @record.send(association_name).destroy @attachment_record
      else
        @record.send("#{association_name}=", nil)
      end

      respond_to do |format|
        format.html { redirect_to params[:referrer] || resource_view_response_path, notice: t("avo.attachment_class_detached", attachment_class: @attachment_class) }
      end
    end

    private

    def set_reflection
      @reflection = @record._reflections[params[:related_name].to_s]
    end

    def set_attachment_class
      @attachment_class = @reflection.klass
    end

    def set_attachment_resource
      @attachment_resource = @field.use_resource || (Avo.resource_manager.get_resource_by_model_class @attachment_class)
    end

    def set_attachment_record
      @attachment_record = @related_resource.find_record attachment_id, params: params
    end

    def set_reflection_field
      @field = @resource.get_field_definitions.find { |f| f.id == @related_resource_name.to_sym }
      @field.hydrate(resource: @resource, record: @record, view: :new)
    rescue
    end

    def attachment_id
      params[:related_id] || params.require(:fields).permit(:related_id)[:related_id]
    end

    def reflection_class
      reflection = @record._reflections[params[:related_name]]

      klass = reflection.class.name.demodulize.to_s
      klass = reflection.through_reflection.class.name.demodulize.to_s if klass == "ThroughReflection"

      klass
    end

    def authorize_if_defined(method)
      @authorization.set_record(@record)

      if @authorization.has_method?(method.to_sym)
        @authorization.authorize_action method.to_sym
      end
    end

    def authorize_index_action
      authorize_if_defined "view_#{@field.id}?"
    end

    def authorize_attach_action
      authorize_if_defined "attach_#{@field.id}?"
    end

    def authorize_detach_action
      authorize_if_defined "detach_#{@field.id}?"
    end

    private

    def set_related_authorization
      @related_authorization = if @related_resource.present?
        @related_resource.authorization(user: _current_user)
      else
        Services::AuthorizationService.new _current_user
      end
    end
  end
end
