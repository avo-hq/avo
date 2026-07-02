module Avo
  module Concerns
    module FormBuilder
      def build_form(&block)
        form_with model: @resource.record,
          scope: @resource.form_scope,
          url: form_url,
          method: is_edit? ? :put : :post,
          local: true,
          html: {
            novalidate: true,
            data: {
              controller: "form avo-reactive-fields",
              action: "keydown.ctrl+enter->form#submit keydown.meta+enter->form#submit"
            }
          },
          multipart: true, &block
      end

      def form_url
        if is_edit?
          helpers.resource_path(
            record: @resource.record,
            resource: @resource
          )
        else
          helpers.resources_path(
            resource: @resource,
            via_relation_class: params[:via_relation_class],
            via_relation: params[:via_relation],
            via_record_id: params[:via_record_id]
          )
        end
      end

      def is_edit?
        @view.in?(%w[edit update])
      end
    end
  end
end
