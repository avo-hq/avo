require_relative 'field'

module Avocado
  module Fields
    class BadgeField < Field
      def initialize(name, **args, &block)
        @defaults = {
          sortable: true,
          component: 'badge-field',
        }

        super(name, **args, &block)

        default_map = { info: :info, success: :success, danger: :danger, warning: :warning }
        @map = args[:map].present? ? default_map.merge(args[:map]) : default_map
      end

      def hydrate_field(fields, model, resource, view)
        if fields[:computed_value].present?
          return {
            value: fields[:computed_value]
          }
        end

        value = {}

        @map.invert.each do |values, type|
          db_value = model[id] || ''

          if [values].flatten.include? db_value.to_sym
            value = {
              label: db_value,
              type: type,
            }
          end
        end

        {
          value: value
        }
      end
    end
  end
end
