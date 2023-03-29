module Avo
  module Dashboards
    class BaseDashboard
      # TODO: convert the dashboards from classes to instances.
      extend Avo::Concerns::VisibleInDashboard
      extend ActiveSupport::DescendantsTracker

      class_attribute :id
      class_attribute :name
      class_attribute :description
      class_attribute :items_holder
      class_attribute :grid_cols, default: 3
      # TODO: remove this when you make the conversion.
      class_attribute :visible, default: true
      class_attribute :index, default: 0
      class_attribute :authorize, default: -> { true }

      class << self
        def options_deprecation_message
          Rails.logger.warn "DEPRECATION WARNING: Card options parameter is deprecated in favor of arguments parameter and will be removed from Avo version 3.0.0"
        end

        def card(klass, label: nil, description: nil, cols: nil, rows: nil, refresh_every: nil, options: {}, arguments: {}, visible: nil)
          options_deprecation_message if options.present?
          self.items_holder ||= []

          self.items_holder << klass.new(
            dashboard: self,
            label: label,
            description: description,
            cols: cols,
            rows: rows,
            refresh_every: refresh_every,
            options: options,
            arguments: arguments,
            index: index,
            visible: visible
          )
          self.index += 1
        end

        def item_at_index(index)
          items.find do |item|
            next if item.index.blank?

            item.index == index
          end
        end

        def divider(**args)
          self.items_holder ||= []

          self.items_holder << BaseDivider.new(dashboard: self, **args)
        end

        def items
          items = self.items_holder || []

          items.filter do |item|
            item.is_visible?
          end
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
          Avo::App.view_context.avo.dashboard_path id
        end
      end
    end
  end
end
