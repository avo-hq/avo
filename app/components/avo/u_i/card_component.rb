# frozen_string_literal: true

class Avo::UI::CardComponent < Avo::BaseComponent
  prop :title
  prop :description
  prop :class
  prop :wrapper_class
  # Opt-in body padding via the `.card--padded` modifier. Defaults to false so
  # cards holding wide content (index tables, scrollers) stay flush to the edge.
  prop :padded, default: -> { false }
  prop :variant, default: -> { :default }
  prop :options, kind: :**
  prop :data, default: -> { {}.freeze }
  prop :index

  renders_one :header
  renders_one :body, "BodyComponent"
  renders_one :footer

  class BodyComponent < Avo::BaseComponent
    prop :class
    prop :data, default: -> { {}.freeze }

    def call
      tag.div class: class_names("card__body", @class), data: {**@data, item_index: @index} do
        content
      end
    end
  end
end
