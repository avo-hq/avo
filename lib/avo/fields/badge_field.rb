module Avo
  module Fields
    class BadgeField < BaseField
      attr_reader :options
      attr_reader :size

      def initialize(id, **args, &block)
        super(id, **args, &block)

        hide_on [:edit, :new]

        default_options = {info: :info, success: :success, danger: :danger, warning: :warning, neutral: :neutral}
        @options = args[:options].present? ? default_options.merge(args[:options]) : default_options
        add_string_prop args, :size, :md # possible values: sm, md
      end
    end
  end
end
