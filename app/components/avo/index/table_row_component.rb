# frozen_string_literal: true

class Avo::Index::TableRowComponent < Avo::BaseComponent
  include Avo::ResourcesHelper

  attr_writer :header_fields

  def initialize(resource: nil, reflection: nil, parent_record: nil, parent_resource: nil, actions: nil, fields: nil, header_fields: nil)
    @resource = resource
    @reflection = reflection
    @parent_record = parent_record
    @parent_resource = parent_resource
    @actions = actions
    @fields = fields
    @header_fields = header_fields
  end

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
