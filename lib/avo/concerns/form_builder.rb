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
              controller: ["form avo-reactive-fields", ("webmcp-form" if webmcp?)].compact.join(" "),
              action: "keydown.ctrl+enter->form#submit keydown.meta+enter->form#submit"
            },
            **webmcp_tool_attributes
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

      private

      # WebMCP's declarative API: `toolname` + `tooldescription` make the form a tool whose schema is read off the
      # inputs. No `toolautosubmit`, on purpose — the agent fills, the person reviews and clicks Save.
      def webmcp_tool_attributes
        return {} unless webmcp?

        if is_edit?
          {
            toolname: "update_#{@resource.class.singular_route_key}",
            tooldescription: "Update the #{@resource.name} \"#{@resource.record_title}\". Fill in only the fields that should change."
          }
        else
          {
            toolname: "create_#{@resource.class.singular_route_key}",
            tooldescription: "Create a new #{@resource.name}."
          }
        end
      end

      def webmcp? = Avo.configuration.webmcp[:enabled]
    end
  end
end
