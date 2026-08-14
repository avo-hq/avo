# frozen_string_literal: true

module Avo
  module Fields
    module Concerns
      module HasResizableEditor
        extend ActiveSupport::Concern

        COMPATIBLE_EDITOR_SELECTORS = {
          "lexical" => "[contenteditable='true']",
          "lexxy" => "lexxy-editor > .lexxy-editor__content",
          "markdown" => ".marksmith-textarea",
          "rhino" => "avo-rhino-editor > .trix-content[slot='editor']"
        }.freeze

        included do
          class_attribute :resizable_editor_selector, instance_writer: false, default: nil
        end

        class_methods do
          # Marks a field as an editor whose editable viewport can be resized.
          # The selector is resolved inside the field wrapper after the editor
          # has initialized, so it also supports client-rendered editors.
          def resizable_editor(target:)
            self.resizable_editor_selector = target
          end
        end

        def resizable_editor?
          resizable_editor_target_selector.present?
        end

        def resizable_editor_target_selector
          self.class.resizable_editor_selector || COMPATIBLE_EDITOR_SELECTORS[type.to_s]
        end
      end
    end
  end
end
