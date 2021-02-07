require_dependency 'avo/base_controller'

module Avo
  class ResourcesController < BaseController
    # def index
    #   super
    # end

    def new
      @model = @resource.model_class.new
      @resource = @resource.hydrate(model: @model, view: :new, user: _current_user)
    end

    def edit
      @resource = @resource.hydrate(model: @model, view: :edit, user: _current_user)
    end

    def create
      @model = @resource.model_class.new(model_params)

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
      @model = @resource.fill_model(@model, cast_nullable(model_params))

      respond_to do |format|
        if @model.save
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
