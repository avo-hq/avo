# frozen_string_literal: true

class Avo::UI::GridItemComponent < Avo::BaseComponent
  prop :image
  prop :checkbox_checked, default: false
  prop :badge_label
  prop :badge_color, default: :blue
  prop :title
  prop :description
  prop :actions
  prop :action_icon, default: "tabler/outline/dots-vertical"
  prop :classes
  # Props for ID generation and data attributes (for action reload compatibility)
  prop :record_id
  prop :resource_model_key

  def component_id
    return nil unless @record_id.present?
    "#{self.class.to_s.underscore}_#{@record_id}"
  end

  def component_data_attributes
    return {} unless @record_id.present?

    data = {
      component_name: self.class.to_s.underscore,
      resource_name: @resource_model_key || "Resource",
      record_id: @record_id.to_s,
      resource_id: @record_id.to_s,
      controller: "item-selector"
    }

    if try(:drag_reorder_item_data_attributes)
      data.merge!(drag_reorder_item_data_attributes)
    end

    data
  end
end
