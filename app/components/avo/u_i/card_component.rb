# frozen_string_literal: true

class Avo::UI::CardComponent < Avo::BaseComponent
  prop :title
  prop :description
  prop :class
  prop :wrapper_class
  prop :with_padding, default: -> { true }
  prop :variant, default: -> { :default }
  prop :options, kind: :**
  prop :data, default: -> { {}.freeze }
  prop :index

  renders_one :header
  renders_one :body, "BodyComponent"
  renders_one :footer

  class BodyComponent < Avo::BaseComponent
    prop :class

    def call
      tag.div class: class_names("card__body", @class), data: {**@data, item_index: @index} do
        content
      end
    end
  end

  private

  # def panel_classes
  #   base_classes = "panel"
  #   variant_classes = case variant
  #                    when :compact
  #                      "panel--compact"
  #                    when :full_width
  #                      "panel--full-width"
  #                    else
  #                      "panel--default"
  #                    end
  #   padding_classes = with_padding ? "panel--with-padding" : ""

  #   [base_classes, variant_classes, padding_classes].compact.join(" ")
  # end

  # def compact?
  #   variant == :compact
  # end

  # def full_width?
  #   variant == :full_width
  # end

  # def with_padding?
  #   with_padding
  # end

  # def header_classes
  #   "panel__header"
  # end

  # def body_classes
  #   "panel__body"
  # end
end
