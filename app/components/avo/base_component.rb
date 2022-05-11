# frozen_string_literal: true

class Avo::BaseComponent < ViewComponent::Base
  def has_with_trial(ability)
    ::Avo::App.license.has_with_trial(ability)
  end

  private

  def can_see_the_back_button?
    Avo.configuration.back_path.present?
  end

  def configured_back_path
    return nil if Avo.configuration.back_path.nil?
    return "javascript:history.back()" if Avo.configuration.back_path == :javascript_history_back

    :computed
  end

  # Figure out what is the corresponding field for this @reflection
  def field
    fields = ::Avo::App.get_resource_by_model_name(@reflection.active_record.name).get_field_definitions
    fields.find { |f| f.id == @reflection.name }
  rescue
    nil
  end

  def relation_resource
    ::Avo::App.get_resource_by_model_name params[:via_resource_class].safe_constantize
  end

  # Get the resource for the resource using the klass attribute so we get the namespace too
  def reflection_resource
    ::Avo::App.get_resource_by_model_name(@reflection.klass.to_s)
  rescue
    nil
  end

  # Get the resource for the resource using the klass attribute so we get the namespace too
  def reflection_parent_resource
    ::Avo::App.get_resource_by_model_name(@reflection.active_record.to_s)
  rescue
    nil
  end
end
