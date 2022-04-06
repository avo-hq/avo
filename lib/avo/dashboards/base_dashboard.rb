module Avo
  module Dashboards
    class BaseDashboard
      extend ActiveSupport::DescendantsTracker

      include Avo::Concerns::HasCards

      class_attribute :id
      class_attribute :name
      class_attribute :description
      class_attribute :visible, default: true
      class_attribute :index, default: 0

      class << self
        def navigation_label
          name
        end

        def navigation_path
          "#{Avo::App.root_path}/dashboards/#{id}"
        end

        def is_visible?
          # Default is true
          return true if visible == true

          # Hide if false
          return false if visible == false

          if visible.respond_to? :call
            ::Avo::Hosts::DashboardVisibility.new(block: visible, dashboard: self).handle
          end
        end

        def is_hidden?
          !is_visible?
        end
      end
    end
  end
end
