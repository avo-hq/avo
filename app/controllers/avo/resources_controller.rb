require_dependency 'avo/application_controller'

module Avo
  class ResourcesController < ApplicationController
    before_action :authorize_user
    before_action :set_model, only: [:show, :edit, :destroy, :update]

    def index
      @resources = resource_model.all.map do |resource|
        Avo::Resources::Resource.hydrate_resource(model: resource, resource: avo_resource, view: :index, user: _current_user)
      end
    end

    def show
      @resource = Avo::Resources::Resource.hydrate_resource(model: @model, resource: avo_resource, view: :show, user: _current_user)
    end

    def edit
      @resource = Avo::Resources::Resource.hydrate_resource(model: @model, resource: avo_resource, view: :show, user: _current_user)
    end

    def update
      # abort model_params.inspect
      respond_to do |format|
        if @model.update(model_params)
          format.html { redirect_to resource_path(@model), notice: "#{@model.class.name} was successfully destroyed." }
          format.json { render :show, status: :ok, location: @post }
        else
          format.html { render :edit }
          format.json { render json: @post.errors, status: :unprocessable_entity }
        end
      end
    end

    def destroy
      @model.destroy!

      respond_to do |format|
        format.html { redirect_to resources_path(@model), notice: "#{@model.class.name} was successfully destroyed." }
        format.json { head :no_content }
      end
    end

    private
      def render(*arguments)
        if @_action_name == 'show'
          set_heading
        end

        super(*arguments)
      end

      def set_heading
        @heading = "#{@resource[:singular_name]} details"
      end

      def model_params
        params.require(@model.model_name.route_key.singularize).permit(permitted_params)
      end

      def permitted_params
        permitted = avo_resource.get_fields.select(&:updatable).map do |field|
          # If it's a relation
          if field.methods.include? :foreign_key
            database_id = field.foreign_key(avo_resource.model)
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
  end
end
