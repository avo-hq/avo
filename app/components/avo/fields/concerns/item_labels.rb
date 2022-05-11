module Avo
  module Fields
    module Concerns
      module ItemLabels
        extend ActiveSupport::Concern

        def value_for_item(item)
          if @field.acts_as_taggable_on.present?
            item["value"]
          else
            item
          end
        end

        def label_from_item(item)
          value = value_for_item item

          if suggestions_are_a_hash?
            return suggestions_by_id[value.to_s][:label] if suggestions_by_id[value.to_s].present?
          end
          value
        end

        def suggestions_by_id
          return {} unless suggestions_are_a_hash?

          @field.suggestions.map do |suggestion|
            [suggestion[:value].to_s, suggestion]
          end.to_h
        end

        def suggestions_are_a_hash?
          return false if @field.suggestions.blank?

          @field.suggestions.first.is_a? Hash
        end
      end
    end
  end
end
