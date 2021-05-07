module Avo
  module Fields
    class TrixField < BaseField
      attr_reader :always_show
      attr_reader :attachments_disabled
      attr_reader :attachment_key

      def initialize(id, **args, &block)
        super(id, **args, &block)

        hide_on :index

        @always_show = args[:always_show] || false
        @attachments_disabled = args[:attachments_disabled] || false
        @attachment_key = args[:attachment_key]
      end
    end
  end
end
