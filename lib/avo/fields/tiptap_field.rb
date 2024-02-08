module Avo
  module Fields
    class TiptapField < BaseField
      attr_reader :options

      def initialize(id, **args, &block)
        super(id, **args, &block)

        hide_on :index

        @always_show = args[:always_show].present? ? args[:always_show] : false
        @height = args[:height].present? ? args[:height].to_s : 'auto'

        @options = {
          always_show: @always_show,
          height: @height
        }
      end
    end
  end
end
