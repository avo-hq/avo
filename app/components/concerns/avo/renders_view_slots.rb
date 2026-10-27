module Avo
  module RendersViewSlots
    def render_index_slot(position, &default)
      render_view_slot(:index, position, &default)
    end

    def render_resource_slot(position, &default)
      view = {"create" => :new, "update" => :edit}.fetch(@view.to_s) { @view.to_sym }
      render_view_slot(view, position, form: @form, &default)
    end

    def render_view_slot(view, position, form: nil, &default)
      form_view = view.in?([:edit, :new])
      if default
        replacement = @resource.public_send(:"#{view}_slot_replacements")[position]
        replacement ||= @resource.form_slot_replacements[position] if form_view
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
        blocks = @resource.public_send(:"#{view}_slots")[position]
        shared = @resource.form_slots[position] if form_view
        return unless blocks || shared

        blocks = [*shared, *blocks] if shared
      end

      helpers.safe_join(blocks.map do |block|
        Avo::ExecutionContext.new(
          target: block,
          view_context: helpers,
          resource: @resource,
          record: @resource.record,
          view: Avo::ViewInquirer.new(view),
          form: form,
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
