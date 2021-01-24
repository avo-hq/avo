module Avo
  module Fields
    class BadgeField < Field
      def initialize(name, **args, &block)
        @defaults = {
          component: 'badge-field',
          # component: 'badge-field', name this partial and add the full path so we can override it
        }

        super(name, **args, &block)

        hide_on [:edit, :new]

        default_options = { info: :info, success: :success, danger: :danger, warning: :warning }
        @meta[:options] = args[:options].present? ? default_options.merge(args[:options]) : default_options
      end
    end
  end
end
