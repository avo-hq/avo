class Avo::ResourceComponent < Avo::BaseComponent
  def can_create?
    return authorize_association_for(:create) if @reflection.present?

    @resource.authorization.authorize_action(:create, raise_exception: false)
  end

  def can_delete?
    return authorize_association_for(:destroy) if @reflection.present?

    @resource.authorization.authorize_action(:destroy, raise_exception: false)
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
end
