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
    association_policy = true

    if @reflection.present?
      reflection_resource = ::Avo::App.get_resource_by_model_name(@reflection.active_record.name)
      reflection_resource.hydrate(model: @parent_model) if @parent_model.present?
      association_name = params["related_name"]

      if association_name.present?
        method_name = "#{policy_method}_#{association_name}?".to_sym

        if reflection_resource.authorization.has_method?(method_name, raise_exception: false)
          association_policy = reflection_resource.authorization.authorize_action(method_name, raise_exception: false)
        end
      end
    end

    association_policy
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
