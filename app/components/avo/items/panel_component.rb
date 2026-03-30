# frozen_string_literal: true

class Avo::Items::PanelComponent < Avo::ResourceComponent
  include Avo::ApplicationHelper

  prop :form
  prop :item
  prop :resource
  prop :view
  prop :actions, reader: :public
  prop :index, reader: :public
  prop :parent_component
  prop :parent_record
  prop :parent_resource
  prop :reflection

  delegate :controls,
    :title,
    :back_path,
    :edit_path,
    :can_see_the_destroy_button?,
    :can_see_the_save_button?,
    to: :@parent_component

  # Warn in development/test when a developer declares fields directly inside a `panel`
  # without wrapping them in a `card do ... end` block.
  #
  # This matters because cards are the thing that provides the consistent background/spacing.
  def fields_outside_card?
    return false unless Rails.env.development? || Rails.env.test?
    return false unless @item.respond_to?(:visible_items)
    return false if @item.respond_to?(:dev_warnings?) && !@item.dev_warnings?

    @item.visible_items.any? do |item|
      # Direct field under the panel will render without card background.
      if item.is_field?
        true
      # Row is rendered directly by the panel too; it can contain fields rendered without card background.
      elsif item.is_row?
        item.visible_items.any?(&:is_field?)
      else
        false
      end
    end
  end

  def card_background_warning_message
    # Keep the message deterministic for specs.
    docs_url = "https://docs.avohq.io/4.0/resource-cards.html"
    code_classes = "rounded bg-orange-500/10 px-1 py-0.5 font-mono text-[0.85em] font-semibold text-orange-950 dark:bg-orange-500/15 dark:text-orange-50"
    disable_snippet = "<code class=\"#{code_classes}\">panel dev_warnings: false do ... end</code>"

    "Some fields are declared directly inside a <code class=\"#{code_classes}\">panel</code> without a <code class=\"#{code_classes}\">card do ... end</code> wrapper. Wrap them in a <code class=\"#{code_classes}\">card</code> to get the expected card background and spacing. If this is intentional and you want to avoid this warning please use #{disable_snippet}. See the <a href=\"#{docs_url}\" target=\"_blank\" rel=\"noopener\" class=\"underline underline-offset-2\">resource cards</a> docs."
  end
end
