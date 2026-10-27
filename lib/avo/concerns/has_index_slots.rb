module Avo
  module Concerns
    module HasIndexSlots
      extend ActiveSupport::Concern

      POSITIONS = %i[
        before_cards after_cards before_header after_header before_title after_title
        before_toolbar after_toolbar before_collection after_collection
        before_records after_records before_pagination after_pagination
      ].freeze
      REGIONS = %i[cards header title toolbar collection records pagination].freeze

      included do
        class_attribute :index_slots, default: {}.freeze, instance_writer: false
        class_attribute :index_slot_replacements, default: {}.freeze, instance_writer: false
      end

      class_methods do
        def index_slot(position, replace: false, &block)
          view_slot(:index, position, replace: replace, &block)
        end

        def view_slot(view, position, replace: false, &block)
          raise ArgumentError, "Unsupported slot view #{view.inspect}. Supported views: index" unless view == :index

          positions = replace ? REGIONS : POSITIONS
          unless positions.include?(position)
            raise ArgumentError, "Unknown index slot #{position.inspect} for replace: #{replace}. Choose from: #{positions.join(", ")}"
          end
          raise ArgumentError, "view_slot requires a block" unless block

          if replace
            if index_slot_replacements.dig(position, :owner) == self
              raise ArgumentError, "Index slot #{position.inspect} already has a replacement on #{self}"
            end

            self.index_slot_replacements = index_slot_replacements.merge(position => {owner: self, block: block}.freeze).freeze
          else
            self.index_slots = index_slots.merge(position => [*index_slots[position], block].freeze).freeze
          end
        end
      end
    end
  end
end
