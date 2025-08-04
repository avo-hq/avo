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

  def render?
    @resource.view_type.to_sym == :table
  end
end
