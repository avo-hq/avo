require_dependency 'avo/application_controller'

module Avo
  class RelationsController < ApplicationController
    before_action :set_resource_name
    before_action :set_resource
    before_action :set_model
    before_action :set_attachment_class
    before_action :set_attachment_resource
    before_action :set_attachment_model, except: :show
    # before_action :authorize_user

    def show
      query = AuthorizationService.with_policy _current_user, @attachment_class

      @options = query.all.map do |model|
        {
          value: model.id,
          label: model.send(@attachment_resource.title)
        }
      end
    end

    def attach
      # @team.admin = @attachment_model
      @model.send("#{params[:attachment_name]}=", @attachment_model)

      respond_to do |format|
        if @model.save
          format.html { redirect_to resource_path(@model), notice: t('avo.attachment_class_attached', attachment_class: @attachment_class) }
          format.json { render :show, status: :created, location: resource_path(@model) }
        else
          format.html { render :new }
          format.json { render json: @model.errors, status: :unprocessable_entity }
        end
      end
    end

    def detach
      @model.send("#{params[:attachment_name]}=", nil)

      respond_to do |format|
        format.html { redirect_to resource_path(@model), notice: t('avo.attachment_class_detached', attachment_class: @attachment_class) }
        format.json { render :show, status: :created, location: resource_path(@model) }
      end
    end

    private
      def set_attachment_class
        @attachment_class = @model._reflections[params[:attachment_name].to_s].klass
      end

      def set_attachment_resource
        @attachment_resource = App.get_resource_by_model_name @attachment_class
      end

      def set_attachment_model
        @attachment_model = @model._reflections[params[:attachment_name].to_s].klass.find attachment_id
      end

      def attachment_id
        params[:attachment_id] or params.require(:fields).permit(:attachment_id)[:attachment_id]
      end
  end
end
