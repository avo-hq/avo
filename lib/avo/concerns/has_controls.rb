module Avo
  module Concerns
    module HasControls
      extend ActiveSupport::Concern
      include Avo::Resources::Controls

      included do
        class_attribute :show_controls
        class_attribute :edit_controls
        class_attribute :index_controls
        class_attribute :row_controls
      end

      # Any change applied here should also be applied on Avo::Advanced::Resources::Controls::ExecutionContext default_controls
      def render_show_controls
        [BackButton.new, DeleteButton.new, DetachButton.new, ActionsList.new, EditButton.new]
      end

      def render_edit_controls
        [BackButton.new(label: I18n.t("avo.cancel").capitalize), DeleteButton.new, ActionsList.new, SaveButton.new(resource: self)]
      end

      def render_index_controls(item:)
        [BackButton.new, AttachButton.new(item: item), ActionsList.new(as_index_control: true), CreateButton.new(item: item)]
      end

      def render_row_controls(item:)
        [
          OrderControls.new,
          ShowButton.new(item: item),
          EditButton.new(item: item),
          DetachButton.new(item: item),
          DeleteButton.new(item: item)
        ]
      end
    end
  end
end
