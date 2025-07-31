# frozen_string_literal: true

class Avo::ResourceBodyContentComponent < Avo::BaseComponent
  prop :resources
  prop :resource
  prop :reflection
  prop :parent_record
  prop :parent_resource
  prop :pagy
  prop :query
  prop :actions
  prop :turbo_frame
  prop :index_params
  prop :field

  def component_id
    "#{@resource.model_key}_body_content"
  end

  def render?
    @resource.view_type.to_sym == :table
  end
end
