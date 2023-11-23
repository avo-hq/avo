# frozen_string_literal: true

module Avo
  module Index
    class KanbanColumnComponent < ViewComponent::Base
      include Avo::ApplicationHelper
      attr_reader :resource
      attr_reader :records
      attr_reader :name

      def initialize(name: "", records: nil, resource: nil)
        @name = name
        @records = records
        @resource = resource
      end
    end
  end
end
