# frozen_string_literal: true

class Avo::Fields::HasOneField::ShowComponent < Avo::Fields::ShowComponent
  include Avo::ApplicationHelper

  def can_attach?
    attach_policy = true
    if @field.present?
      reflection_resource = @field.target_resource
      if reflection_resource.present? && @resource.present?
        method_name = ('attach_' + reflection_resource.model_class.model_name.singular_route_key.underscore + '?').to_sym
        defined_policy_methods = @resource.authorization.defined_methods(@resource.model_class, raise_exception: false)
        if defined_policy_methods.present? && defined_policy_methods.include?(method_name)
          attach_policy = @resource.authorization.authorize_action(method_name, raise_exception: false)
        end
      end
    end
    attach_policy
  end
end
