# frozen_string_literal: true

module Avo
  module Index
    class ResourceKanbanComponent < ViewComponent::Base
      include Avo::ApplicationHelper

      attr_reader :resources
      attr_reader :resource

      def initialize(resources: nil, resource: nil, reflection: nil, parent_record: nil, parent_resource: nil, pagy: nil, query: nil, actions: nil)
        @resources = resources
        @resource = resource
        @reflection = reflection
        @parent_record = parent_record
        @parent_resource = parent_resource
        @pagy = pagy
        @query = query
        @actions = actions
      end

      def column_attribute
        resource.class.kanban_view[:column]
      end

      def columns
        @query.pluck(column_attribute).uniq
      end

      def records_for_column(column)
        @query.where(column_attribute => column)
      end
    end
  end
end
