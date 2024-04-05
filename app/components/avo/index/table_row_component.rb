# frozen_string_literal: true

class Avo::Index::TableRowComponent < Avo::BaseComponent
  include Avo::ResourcesHelper

  def initialize(resource: nil, reflection: nil, parent_record: nil, parent_resource: nil, actions: nil, fields: nil, header_fields: nil)
    @resource = resource
    @reflection = reflection
    @parent_record = parent_record
    @parent_resource = parent_resource
    @actions = actions
    @fields = fields
    @header_fields = header_fields
  end
end
