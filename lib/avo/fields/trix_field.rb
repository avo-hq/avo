module Avo
  module Fields
    class TrixField < BaseField
      attr_reader :always_show
      attr_reader :attachments_disabled
      attr_reader :attachment_key

      def initialize(name, **args, &block)
        @defaults = {
          partial_name: "trix-field"
        }

        super(name, **args, &block)

        hide_on :index

        @always_show = args[:always_show].present? ? args[:always_show] : false
        @attachments_disabled = args[:attachments_disabled].present? ? args[:attachments_disabled] : false
        @attachment_key = args[:attachment_key].present? ? args[:attachment_key] : nil
      end
    end
  end
end
