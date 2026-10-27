module Avo
  module RendersIndexSlots
    def render_index_slot(position, &default)
      if default
        replacement = @resource.index_slot_replacements[position]
        return capture(&default) unless replacement

        captured = false
        content = nil
        default_content = -> {
          unless captured
            content = capture(&default)
            captured = true
          end
          content
        }
        blocks = [replacement[:block]]
      else
        blocks = @resource.index_slots[position]
        return unless blocks
      end

      helpers.safe_join(blocks.map do |block|
        Avo::ExecutionContext.new(
          target: block,
          view_context: helpers,
          resource: @resource,
          resources: @resources,
          query: @query,
          pagy: @pagy,
          parent_record: @parent_record,
          parent_resource: @parent_resource,
          view_type: @resource.view_type,
          **(default ? {default_content: default_content} : {})
        ).handle
      end)
    end
  end
end
