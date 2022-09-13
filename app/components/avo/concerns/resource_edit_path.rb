module Avo
  module Concerns
    module ResourceEditPath
      extend ActiveSupport::Concern

      def edit_path
        # Add the `view` param to let Avo know where to redirect back when the user clicks the `Cancel` button.
        args = {via_view: "index"}

        if @parent_model.present?
          args = {
            via_resource_class: @parent_resource.model_class,
            via_resource_id: @parent_model.id
          }
        end

        helpers.edit_resource_path(model: @resource.model, resource: @resource, **args)
      end

      def parent_resource
        return nil if @parent_model.blank?

        ::Avo::App.get_resource_by_model_name @parent_model.class
      end

    end
  end
end
