# frozen_string_literal: true

class Avo::Index::TableRowComponent < Avo::BaseComponent
  include Avo::ResourcesHelper
  include Avo::Concerns::ChecksShowAuthorization

  attr_writer :header_fields

  prop :resource, _Nilable(Avo::BaseResource)
  prop :reflection, _Nilable(ActiveRecord::Reflection::AbstractReflection)
  prop :parent_record, _Nilable(_Any)
  prop :parent_resource, _Nilable(Avo::BaseResource)
  prop :actions, _Nilable(_Array(Avo::BaseAction))
  prop :fields, _Nilable(_Array(Avo::Fields::BaseField))
  prop :header_fields, _Nilable(_Array(String))

  def resource_controls_component
    Avo::Index::ResourceControlsComponent.new(
      resource: @resource,
      reflection: @reflection,
      parent_record: @parent_record,
      parent_resource: @parent_resource,
      view_type: :table,
      actions: @actions
    )
  end

  def click_row_to_view_record
    return false unless Avo.configuration.click_row_to_view_record

    can_view?
  end
end
