module Avocado
  module Fields
    class StatusField < Field
      def initialize(name, **args, &block)
        @defaults = {
          sortable: true,
          component: 'status-field',
        }

        super(name, **args, &block)

        @loading_when = args[:loading_when].present? ? [args[:loading_when]].flatten : [:waiting, :running]
        @failed_when = args[:failed_when].present? ? [args[:failed_when]].flatten : [:failed]
      end

      def hydrate_field(fields, model, resource, view)
        {
          loading_when: @loading_when,
          failed_when: @failed_when,
        }
      end
    end
  end
end
