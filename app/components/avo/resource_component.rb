class Avo::ResourceComponent < ViewComponent::Base
  def can_create?
    @resource.authorization.authorize_action(:create, raise_exception: false)
  end

  def can_delete?
    @resource.authorization.authorize_action(:destroy, raise_exception: false)
  end

  def authorize_association_for(policy_method)
    association_policy = true
    if @reflection.present?
      reflection_resource = ::Avo::App.get_resource_by_model_name(@reflection.active_record.name)
      if reflection_resource.present?
        method_name = ("#{policy_method}_#{@reflection.name.to_s.underscore}?").to_sym
        defined_policy_methods = reflection_resource.authorization.defined_methods(reflection_resource.model_class, raise_exception: false)
        if defined_policy_methods.present? && defined_policy_methods.include?(method_name)
          association_policy = reflection_resource.authorization.authorize_action(method_name, raise_exception: false)
        end
      end
    end

    association_policy
  end

  private

  def simple_relation?
    @reflection.is_a? ::ActiveRecord::Reflection::HasManyReflection
  end
end
