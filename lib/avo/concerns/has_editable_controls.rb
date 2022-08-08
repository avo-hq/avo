module Avo
  module Concerns
    module HasEditableControls
      extend ActiveSupport::Concern

      included do
        class_attribute :show_controls
        class_attribute :show_controls_holder
        class_attribute :show_controls_holder_called, default: false
      end

      def has_show_controls?
        return false if ::Avo::App.license.lacks_with_trial(:resource_show_controls)

        self.class.show_controls.present?
      end

      def render_show_controls
        return [] if ::Avo::App.license.lacks_with_trial(:resource_show_controls)

        if show_controls.present?
          Avo::Resources::Controls::ExecutionContext.new(
            block: show_controls,
            resource: self,
            record: model,
            view: view
          ).handle.items
        else
          []
        end
      end
    end
  end
end
