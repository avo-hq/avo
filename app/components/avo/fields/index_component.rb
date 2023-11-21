# frozen_string_literal: true

class Avo::Fields::IndexComponent < Avo::BaseComponent
  include Avo::ResourcesHelper

  attr_reader :field
  attr_reader :parent_resource
  attr_reader :view

  def initialize(field: nil, resource: nil, reflection: nil, index: 0, parent_record: nil, parent_resource: nil)
    @field = field
    @resource = resource
    @index = index
    @parent_record = parent_record
    @parent_resource = parent_resource
    @view = Avo::ViewInquirer.new("index")
    @reflection = reflection
  end

  def resource_view_path
    args = {}

    if @parent_record.present?
      args = {
        via_resource_class: @parent_resource.class,
        via_record_id: @parent_record.to_param
      }
    end

    helpers.resource_view_path(record: @resource.record, resource: parent_or_child_resource, **args)
  end

  def field_wrapper_args
    {
      field: @field,
      resource: @resource
    }
  end
end
