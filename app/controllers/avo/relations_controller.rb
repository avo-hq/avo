require_dependency 'avo/base_controller'

module Avo
  class RelationsController < BaseController
    before_action :set_model, only: [:show, :index, :new, :create, :destroy]
    before_action :set_related_resource_name
    before_action :set_related_resource
    before_action :hydrate_related_resource
    before_action :set_related_model, only: [:show]
    before_action :set_attachment_class
    before_action :set_attachment_resource
    before_action :set_attachment_model, only: [:create]
    before_action :set_reflection, only: [:index]

    def index
      @parent_resource = @resource.dup
      # abort @parent_resource.inspect
      @resource = @related_resource
      @parent_model = @parent_resource.model_class.find(params[:id])
      @query = @parent_model.public_send(params[:related_name])
      # abort @query.inspect
      # related_model.find(params[:via_resource_id]).public_send(params[:via_relationship])

      super
    end

    def show
      @reflection = params[:related_name]
      @resource, @model = @related_resource, @related_model

      super
    end

    def new
      query = @authorization.apply_policy @attachment_class

      @options = query.all.map do |model|
        {
          value: model.id,
          label: model.send(@attachment_resource.title)
        }
      end
    end

    def create
      if @model._reflections[params[:related_name]].class.name.demodulize.to_s.in? ['ThroughReflection', 'HasManyReflection']
        @model.send("#{params[:related_name]}") << @attachment_model
      else
        @model.send("#{params[:related_name]}=", @attachment_model)
      end

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

    def destroy
      if @model._reflections[params[:related_name]].class.name.demodulize.to_s.include? 'ThroughReflection'
        @model.send("#{params[:related_name]}").delete @attachment_model
      else
        @model.send("#{params[:related_name]}=", nil)
      end

      respond_to do |format|
        format.html { redirect_to resource_path(@model), notice: t('avo.attachment_class_detached', attachment_class: @attachment_class) }
        format.json { render :show, status: :created, location: resource_path(@model) }
      end
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
        params[:related_id] or params.require(:fields).permit(:related_id)[:related_id]
      end
  end
end
