# frozen_string_literal: true

class Avo::Index::TableRowComponent < Avo::BaseComponent
  include Avo::ResourcesHelper
  include Avo::Concerns::CanReorderItems

  def initialize(resource: nil, reflection: nil, parent_record: nil, parent_resource: nil, actions: nil)
    @resource = resource
    @reflection = reflection
    @parent_record = parent_record
    @parent_resource = parent_resource
    @actions = actions
  end
end
