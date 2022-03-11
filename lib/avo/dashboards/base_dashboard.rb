module Avo
  module Dashboards
    class BaseDashboard
      extend ActiveSupport::DescendantsTracker

      class_attribute :id
      class_attribute :name
      class_attribute :description
      class_attribute :card_holder
      class_attribute :grid_cols, default: 3

      class << self
        def card(klass)
          self.card_holder ||= []

          self.card_holder << klass.new(dashboard: self)
        end

        def cards
          self.card_holder
        end

        def classes
          case grid_cols
          when 3
            "grid-cols-3"
          when 4
            "grid-cols-4"
          when 5
            "grid-cols-5"
          when 6
            "grid-cols-6"
          else
            "grid-cols-3"
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
