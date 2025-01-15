module Avo
  module Fields
    class EasyMdeField < BaseField
      attr_reader :options

      def initialize(id, **args, &block)
        super(id, **args, &block)

        hide_on :index

        @options = {
          spell_checker:args[:spell_checker] || false,
          always_show: args[:always_show] || false,
          height: args[:height]&.to_s || "auto"
        }
      end
    end
  end
end
