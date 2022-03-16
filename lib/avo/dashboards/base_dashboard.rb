module Avo
  module Dashboards
    class BaseDashboard
      extend ActiveSupport::DescendantsTracker

      class_attribute :id
      class_attribute :name
      class_attribute :description
      class_attribute :items_holder
      class_attribute :grid_cols, default: 3

      class << self
        def card(klass)
          self.items_holder ||= []

          self.items_holder << klass.new(dashboard: self)
        end

        def divider(**args)
          self.items_holder ||= []

          self.items_holder << BaseDivider.new(**args)
        end

        def items
          self.items_holder
        end

        def classes
          case grid_cols
          when 3
            "sm:grid-cols-3"
          when 4
            "sm:grid-cols-4"
          when 5
            "sm:grid-cols-5"
          when 6
            "sm:grid-cols-6"
          else
            "sm:grid-cols-3"
          end
        end

        def navigation_label
          name
        end

        def navigation_path
          "#{Avo::App.root_path}/dashboards/#{id}"
        end
      end
    end
  end
end
