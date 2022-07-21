module Avo
  module Concerns
    module HasEditableControls
      extend ActiveSupport::Concern

      included do
        class_attribute :show_controls
        class_attribute :show_controls_holder
        class_attribute :show_controls_holder_called, default: false
      end

      def render_show_controls
        if show_controls.present?
          show_controls_holder = Avo::Resources::Controls::ExecutionContext.new(block: show_controls, resource: self, model: model, view: self.view).handle
          show_controls_holder.items
        else
          []
        end
      end
    end
  end
end
