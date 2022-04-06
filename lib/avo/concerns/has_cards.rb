module Avo
  module Concerns
    module HasCards
      extend ActiveSupport::Concern

      included do
        class_attribute :items_holder
        class_attribute :items_index, default: 0
        class_attribute :grid_cols, default: 3
      end

      class_methods do
        def card(klass, label: nil, description: nil, cols: nil, rows: nil, refresh_every: nil, options: {})
          self.items_holder ||= []

          self.items_holder << klass.new(
            parent: self,
            options: options,
            index: items_index,
            label: label,
            description: description,
            cols: cols,
            rows: rows,
            refresh_every: refresh_every,
          )
          self.items_index += 1
        end

        def item_at_index(index)
          items.find do |item|
            next if item.index.blank?

            item.index == index
          end
        end

        def divider(**args)
          self.items_holder ||= []

          self.items_holder << Avo::Dashboards::BaseDivider.new(**args)
        end

        def items
          self.items_holder
        end

        def items_classes
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
      end
    end
  end
end
