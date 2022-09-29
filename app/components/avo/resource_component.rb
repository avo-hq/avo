class Avo::ResourceComponent < Avo::BaseComponent
  attr_reader :fields_by_panel
  attr_reader :has_one_panels
  attr_reader :has_many_panels
  attr_reader :has_as_belongs_to_many_panels
  attr_reader :resource_tools
  attr_reader :resource
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
    authorize_association_for(:detach)
  end

  def detach_path
    return "/" if @reflection.blank?

    helpers.resource_detach_path(params[:resource_name], params[:id], @reflection.name.to_s, @resource.model.id)
  end

  def can_see_the_edit_button?
    @resource.authorization.authorize_action(:edit, raise_exception: false)
  end

  def can_see_the_destroy_button?
    @resource.authorization.authorize_action(:destroy, raise_exception: false)
  end

  def can_see_the_actions_button?
    return false if @actions.blank?

    return authorize_association_for(:act_on) if @reflection.present?

    @resource.authorization.authorize_action(:act_on, raise_exception: false) && !has_reflection_and_is_read_only
  end

  def destroy_path
    if params[:via_resource_class].present?
      helpers.resource_path(model: @resource.model, resource: @resource, referrer: back_path)
    else
      helpers.resource_path(model: @resource.model, resource: @resource)
    end
  end

  def authorize_association_for(policy_method)
    policy_result = true

    if @reflection.present?
      # Fetch the appropiate resource
      reflection_resource = field.resource
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

  def has_reflection_and_is_read_only
    if @reflection.present? && @reflection.active_record.name && @reflection.name
      fields = ::Avo::App.get_resource_by_model_name(@reflection.active_record.name).get_field_definitions
      filtered_fields = fields.filter { |f| f.id == @reflection.name }
    else
      return false
    end

    if filtered_fields.present?
      filtered_fields.find { |f| f.id == @reflection.name }.readonly
    else
      false
    end
  end

  private

  def via_resource?
    (params[:via_resource_class].present? || params[:via_relation_class].present?) && params[:via_resource_id].present?
  end
end
