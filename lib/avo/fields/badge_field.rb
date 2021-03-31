module Avo
  module Fields
    class BadgeField < BaseField
      def initialize(name, **args, &block)
        @defaults = {
          partial_name: "badge-field"
        }

        super(name, **args, &block)

        hide_on [:edit, :new]

        default_options = {info: :info, success: :success, danger: :danger, warning: :warning}
        @meta[:options] = args[:options].present? ? default_options.merge(args[:options]) : default_options
      end
    end
  end
end
