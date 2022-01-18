module Avo
  module Dashboards
    class Card
      attr_reader :instance
      attr_reader :dashboard

      delegate :cols, to: :instance
      delegate :label, to: :instance
      delegate :range, to: :instance
      delegate :ranges, to: :instance
      delegate :description, to: :instance
      delegate :refresh_every, to: :instance

      def initialize(
        klass: nil,
        dashboard: nil
      )
        @klass = klass
        @dashboard = dashboard

        if @klass.present?
          @instance = klass.new dashboard: @dashboard
        end
      end

      def id
        self.instance.class.id
      end

      def turbo_frame
        "#{dashboard.id}_#{id}"
      end

      def frame_url(enforced_range: nil)
        enforced_range ||= range || ranges.first
        "#{Avo::App.root_path}/dashboards/#{dashboard.id}/cards/#{id}?turbo_frame=#{turbo_frame}&range=#{enforced_range}"
      end

      def card_classes
        case cols.to_i
        when 1
          'col-span-1'
        when 2
          'col-span-2'
        when 3
          'col-span-3'
        when 4
          'col-span-4'
        when 5
          'col-span-5'
        when 6
          'col-span-6'
        else
          'col-span-1'
        end
      end

      def type
        return :metric if instance.class.superclass == ::Avo::Dashboards::MetricCard
        return :chartkick if instance.class.superclass == ::Avo::Dashboards::ChartkickCard
        return :partial if instance.class.superclass == ::Avo::Dashboards::PartialCard
      end
    end
  end
end
