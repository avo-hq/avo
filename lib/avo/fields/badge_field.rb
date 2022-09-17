module Avo
  module Fields
    class BadgeField < BaseField
      attr_reader :options

      def initialize(id, **args, &block)
        super(id, **args, &block)

        hide_on [:edit, :new]

        default_options = {info: :info, success: :success, danger: :danger, warning: :warning}
        @options = args[:options].present? ? default_options.merge(args[:options]) : default_options
      end
    end
  end
end
