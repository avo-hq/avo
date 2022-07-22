class Avo::ResourceComponent < Avo::BaseComponent
  attr_reader :fields_by_panel
  attr_reader :has_one_panels
  attr_reader :has_many_panels
  attr_reader :has_as_belongs_to_many_panels
  attr_reader :resource_tools
  attr_reader :view

  def can_create?
    return authorize_association_for(:create) if @reflection.present?

    @resource.authorization.authorize_action(:create, raise_exception: false)
  end

  def can_delete?
    return authorize_association_for(:destroy) if @reflection.present?

    @resource.authorization.authorize_action(:destroy, raise_exception: false)
  end

  def can_detach?
    authorize_association_for("detach")
  end

  def can_see_the_edit_button?
    @resource.authorization.authorize_action(:edit, raise_exception: false)
  end

  def can_see_the_destroy_button?
    @resource.authorization.authorize_action(:destroy, raise_exception: false)
  end

  def detach_path
    helpers.resource_detach_path(params[:resource_name], params[:id], @reflection.name.to_s, @resource.model.id)
  end

  def destroy_path
    helpers.resource_path(model: @resource.model, resource: @resource)
  end

  def authorize_association_for(policy_method)
    policy_result = true

    if @reflection.present?
      # Fetch the appropiate resource
      reflection_resource = ::Avo::App.get_resource_by_model_name(@reflection.active_record.name)
      # Fetch the model
      # Hydrate the resource with the model if we have one
      reflection_resource.hydrate(model: @parent_model) if @parent_model.present?
      # Use the related_name as the base of the association
      association_name = @reflection.name

      if association_name.present?
        method_name = "#{policy_method}_#{association_name}?".to_sym
        # Prepare the authorization service
        service = reflection_resource.authorization

        if service.has_method?(method_name, raise_exception: false)
          policy_result = service.authorize_action(method_name, raise_exception: false)
        end
      end
    end

    policy_result
  end

  def main_panel
    @resource.get_items.find do |item|
      item.is_main_panel?
    end
  end

  private

  def via_resource?
    params[:via_resource_class].present? && params[:via_resource_id].present?
  end
end
