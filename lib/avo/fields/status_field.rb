module Avo
  module Fields
    class StatusField < BaseField
      def initialize(id, **args, &block)
        super(id, **args, &block)

        @loading_when = args[:loading_when].present? ? [args[:loading_when]].flatten.map(&:to_sym) : []
        @failed_when = args[:failed_when].present? ? [args[:failed_when]].flatten.map(&:to_sym) : []
        @success_when = args[:success_when].present? ? [args[:success_when]].flatten.map(&:to_sym) : []
        @neutral_when = args[:neutral_when].present? ? [args[:neutral_when]].flatten.map(&:to_sym) : []
      end

      def status
        status = "neutral"

        if value.present?
          status = "failed" if @failed_when.include? value.to_sym
          status = "loading" if @loading_when.include? value.to_sym
          status = "success" if @success_when.include? value.to_sym
        end

        status
      end

      def options_for_filter
        [@failed_when, @loading_when, @success_when, @neutral_when].flatten.uniq
      end
    end
  end
end
