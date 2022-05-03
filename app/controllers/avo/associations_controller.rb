require_dependency "avo/base_controller"

module Avo
  class AssociationsController < BaseController
    before_action :set_model, only: [:show, :index, :new, :create, :destroy, :order]
    before_action :set_related_resource_name
    before_action :set_related_resource, only: [:show, :index, :new, :create, :destroy, :order]
    before_action :hydrate_related_resource, only: [:show, :index, :new, :create, :destroy, :order]
    before_action :set_related_model, only: [:show, :order]
    before_action :set_attachment_class, only: [:show, :index, :new, :create, :destroy, :order]
    before_action :set_attachment_resource, only: [:show, :index, :new, :create, :destroy, :order]
    before_action :set_attachment_model, only: [:create, :destroy, :order]
    before_action :set_reflection, only: [:index, :show, :order]

    def index
      @parent_resource = @resource.dup
      @resource = @related_resource
      @parent_model = @parent_resource.class.find_scope.find(params[:id])
      @parent_resource.hydrate(model: @parent_model)
      @query = @authorization.apply_policy @parent_model.public_send(params[:related_name])
      @association_field = @parent_resource.get_field params[:related_name]

      if @association_field.present? && @association_field.scope.present?
        @query = Avo::Hosts::AssociationScopeHost.new(block: @association_field.scope, query: @query, parent: @parent_model).handle
      end

      super
    end

    def show
      @resource, @model = @related_resource, @related_model

      super
    end

    def new
      @resource.hydrate(model: @model)

      begin
        @field = @resource.get_field_definitions.find { |f| f.id == @related_resource_name.to_sym }
        @field.hydrate(resource: @resource, model: @model, view: :new)
      rescue
      end

      if @field.present? && !@field.searchable
        query = @authorization.apply_policy @attachment_class

        # Add the association scope to the query scope
        if @field.scope.present?
          query = Avo::Hosts::AssociationScopeHost.new(block: @field.scope, query: query, parent: @model).handle
        end

        @options = query.all.map do |model|
          [model.send(@attachment_resource.class.title), model.id]
        end
      end
    end

    def create
      if reflection_class == "HasManyReflection"
        @model.send(params[:related_name].to_s) << @attachment_model
      else
        @model.send("#{params[:related_name]}=", @attachment_model)
      end

      respond_to do |format|
        if @model.save
          format.html { redirect_back fallback_location: resource_path(model: @model, resource: @resource), notice: t("avo.attachment_class_attached", attachment_class: @related_resource.name) }
        else
          format.html { render :new }
        end
      end
    end

    def destroy
      if reflection_class == "HasManyReflection"
        @model.send(params[:related_name].to_s).delete @attachment_model
      else
        @model.send("#{params[:related_name]}=", nil)
      end

      respond_to do |format|
        format.html { redirect_to params[:referrer] || resource_path(model: @model, resource: @resource), notice: t("avo.attachment_class_detached", attachment_class: @attachment_class) }
      end
    end

    def order
      @parent_resource = @resource.dup
      @resource, @model = @related_resource, @related_model

      super
    end

    private

    def set_attachment_class
      @attachment_class = @model._reflections[params[:related_name].to_s].klass
    end

    def set_attachment_resource
      @attachment_resource = App.get_resource_by_model_name @attachment_class
    end

    def set_attachment_model
      @attachment_model = @model._reflections[params[:related_name].to_s].klass.find attachment_id
    end

    def set_reflection
      @reflection = @model._reflections[params[:related_name].to_s]
    end

    def attachment_id
      params[:related_id] || params.require(:fields).permit(:related_id)[:related_id]
    end

    def reflection_class
      reflection = @model._reflections[params[:related_name]]

      klass = reflection.class.name.demodulize.to_s
      klass = reflection.through_reflection.class.name.demodulize.to_s if klass == "ThroughReflection"

      klass
    end
  end
end
