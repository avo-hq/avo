# frozen_string_literal: true

module Avo
  module Index
    class KanbanItemComponent < ViewComponent::Base
      attr_reader :resource
      attr_reader :column_name
      attr_reader :record

      def initialize(column_name: "", record: nil, resource: nil)
        @column_name = column_name
        @record = record
        @resource = resource
      end

      def title_attribute
        resource.class.kanban_view.dig(:record, :title)
      end

      def description_attribute
        resource.class.kanban_view.dig(:record, :description)
      end

      def title
        record.send(title_attribute)
      end

      def description
        record.send(description_attribute).truncate 120
      end
    end
  end
end
