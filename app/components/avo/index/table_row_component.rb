# frozen_string_literal: true

class Avo::Index::TableRowComponent < Avo::BaseComponent
  include Avo::ResourcesHelper

  attr_writer :header_fields

  prop :resource, _Nilable(Avo::BaseResource)
  prop :reflection, _Nilable(ActiveRecord::Reflection::AbstractReflection)
  prop :parent_record, _Nilable(ActiveRecord::Base)
  prop :parent_resource, _Nilable(Avo::BaseResource)
  prop :actions, _Nilable(_Array(Avo::BaseAction))
  prop :fields, _Nilable(_Array(Avo::Fields::BaseField))
  prop :header_fields, _Nilable(_Array(Avo::Fields::BaseField))

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

  def click_row_to_view_record = Avo.configuration.click_row_to_view_record
end
