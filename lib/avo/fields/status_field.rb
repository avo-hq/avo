module Avo
  module Fields
    class StatusField < BaseField
      def initialize(id, **args, &block)
        super(id, **args, &block)

        @loading_when = args[:loading_when].present? ? [args[:loading_when]].flatten : [:waiting, :running]
        @failed_when = args[:failed_when].present? ? [args[:failed_when]].flatten : [:failed]
      end

      def status
        status = "success"
        if value.present?
          status = "failed" if @failed_when.include? value.to_sym
          status = "loading" if @loading_when.include? value.to_sym
        end

        status
      end
    end
  end
end
