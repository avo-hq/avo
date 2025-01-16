# frozen_string_literal: true

class Avo::Index::TableRowComponent < Avo::BaseComponent
  include Avo::ResourcesHelper
  include Avo::Concerns::ChecksShowAuthorization

  attr_writer :header_fields

  prop :resource, reader: :public
  prop :reflection
  prop :parent_record
  prop :parent_resource
  prop :actions
  prop :fields
  prop :header_fields
  prop :index

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
    Avo.configuration.click_row_to_view_record && can_view?
  end
end
