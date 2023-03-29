module Avo
  module Concerns
    module VisibleInDashboard
      extend ActiveSupport::Concern

      included do
        class_attribute :visible, default: true
      end

      def is_visible?
        # Default is true
        return true if visible == true

        # Hide if false
        return false if visible == false

        if visible.respond_to? :call
          call_block
        end
      end

      def is_hidden?
        !is_visible?
      end

      def call_block
        ::Avo::Hosts::DashboardVisibility.new(block: visible, dashboard: self).handle
      end
    end
  end
end
