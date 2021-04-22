module Avo
  module Fields
    class MarkdownField < BaseField
      attr_reader :options

      def initialize(id, **args, &block)
        super(id, **args, &block)

        hide_on :index

        @always_show = args[:always_show].present? ? args[:always_show] : false
        @height = args[:height].present? ? args[:height].to_s : "auto"
        @spell_checker = args[:spell_checker].present? ? args[:spell_checker] : false
        @options = {
          spell_checker: @spell_checker,
          always_show: @always_show,
          height: @height
        }
      end
    end
  end
end
