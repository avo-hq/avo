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
end
