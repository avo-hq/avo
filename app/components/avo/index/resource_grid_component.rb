# frozen_string_literal: true

class Avo::Index::ResourceGridComponent < ViewComponent::Base
  attr_reader :actions

  def initialize(resources: nil, resource: nil, reflection: nil, parent_record: nil, parent_resource: nil, actions: nil)
    @resources = resources
    @resource = resource
    @reflection = reflection
    @parent_record = parent_record
    @parent_resource = parent_resource
    @actions = actions
  end
end
