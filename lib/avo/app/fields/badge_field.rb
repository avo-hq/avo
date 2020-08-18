module Avo
  module Fields
    class BadgeField < Field
      def initialize(name, **args, &block)
        @defaults = {
          sortable: true,
          component: 'badge-field',
        }

        super(name, **args, &block)

        hide_on [:edit, :create]

        default_options = { info: :info, success: :success, danger: :danger, warning: :warning }
        @options = args[:options].present? ? default_options.merge(args[:options]) : default_options
      end

      def hydrate_field(fields, model, resource, view)
        if fields[:computed_value].present?
          return {
            value: fields[:computed_value]
          }
        end

        value = {}

        @options.invert.each do |values, type|
          db_value = model[id] || ''

          if [values].flatten.map { |value| value.to_s }.include? db_value
            value = {
              label: db_value,
              type: type,
            }
            next
          end
        end

        {
          value: value
        }
      end
    end
  end
end
