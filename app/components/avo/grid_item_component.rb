# frozen_string_literal: true

module Avo
  class GridItemComponent < ViewComponent::Base
    attr_reader :resource
    attr_reader :reflection
    attr_reader :grid_fields

    def initialize(resource: resource, reflection: reflection)
      @resource = resource
      @reflection = reflection
      @grid_fields = resource.get_fields(view_type: :grid)
    end

    private
      def preview
        grid_fields.detect do |field|
          field.show_on_grid == :preview
        end
      end

      def title
        grid_fields.detect do |field|
          field.show_on_grid == :title
        end
      end

      def body
        grid_fields.detect do |field|
          field.show_on_grid == :body
        end
      end
  end
end
