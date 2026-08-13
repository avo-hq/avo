module Avo
  module Fields
    class TiptapField < BaseField
      resizable_editor target: ".tiptap.ProseMirror"

      attr_reader :always_show

      def initialize(id, **args, &block)
        super

        hide_on :index

        @always_show = args[:always_show] || false
      end
    end
  end
end
