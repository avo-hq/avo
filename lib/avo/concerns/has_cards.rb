module Avo
  module Concerns
    module HasCards
      extend ActiveSupport::Concern

      included do
        class_attribute :cards_holder
        class_attribute :cards_index, default: 0
        class_attribute :grid_cols, default: 3
      end

      class_methods do
        def card(klass, label: nil, description: nil, cols: nil, rows: nil, refresh_every: nil, options: {})
          self.cards_holder ||= []

          self.cards_holder << klass.new(
            parent: self,
            options: options,
            index: cards_index,
            label: label,
            description: description,
            cols: cols,
            rows: rows,
            refresh_every: refresh_every,
          )
          self.cards_index += 1
        end

        def item_at_index(index)
          cards.find do |item|
            next if item.index.blank?

            item.index == index
          end
        end

        def divider(**args)
          self.cards_holder ||= []

          self.cards_holder << Avo::Dashboards::BaseDivider.new(**args)
          self.cards_index += 1
        end

        def cards
          self.cards_holder
        end

        def cards_classes
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

      def cards(params: nil)
        self.class.cards.map do |card|
          # Only try to hydrate cards
          card.hydrate(parent: self, params: params) if card.is_card?

          card
        end
      end
    end
  end
end
