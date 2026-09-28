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
              controller: ["form", "avo-reactive-fields", ("unsaved-changes" if warn_on_unsaved_changes?)].compact.join(" "),
              action: "keydown.ctrl+enter->form#submit keydown.meta+enter->form#submit",
              **unsaved_changes_values
            }
          },
          multipart: true, &block
      end

      # A form inside a modal gets closed, not navigated away from.
      def warn_on_unsaved_changes?
        Avo.configuration.warn_on_unsaved_changes && !embedded_in_modal?
      end

      def unsaved_changes_values
        return {} unless warn_on_unsaved_changes?

        {
          unsaved_changes_message_value: t("avo.unsaved_changes_warning"),
          # A form re-rendered with errors holds values that were never saved.
          unsaved_changes_changed_on_load_value: @resource.record.errors.any?
        }
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
