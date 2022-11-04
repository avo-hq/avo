# frozen_string_literal: true

class Avo::Fields::HasOneField::ShowComponent < Avo::Fields::ShowComponent
  include Avo::ApplicationHelper

  def can_attach?
    policy_result = true

    if @field.present?
      reflection_resource = @field.target_resource
      if reflection_resource.present? && @resource.present?
        method_name = "attach_#{@field.id}?".to_sym

        if @resource.authorization.has_method?(method_name, raise_exception: false)
          policy_result = @resource.authorization.authorize_action(method_name, raise_exception: false)
        end
      end
    end

    policy_result
  end

  def attach_path
    helpers.avo.resources_associations_new_path(@resource.singular_model_key, @resource.model.id, @field.id)
  end

  def can_see_the_create_button?
    create = "create_#{@field.id.to_s}?"

    authorization_service = @resource.authorization

    # By default return true if the create method is not defined for this field
    return true unless authorization_service.has_method?(create, raise_exception: false)

    authorization_service.authorize_action(create, raise_exception: false)
  end

  def create_path
    args = {
      via_relation: @resource.singular_model_key,
      via_relation_class: @resource.model_class.to_s,
      via_resource_id: @resource.model.id
    }
    helpers.new_resource_path(resource: @field.target_resource, **args)
  end
end
