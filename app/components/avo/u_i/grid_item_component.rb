# frozen_string_literal: true

class Avo::UI::GridItemComponent < Avo::BaseComponent
  prop :image
  prop :checkbox_checked, default: false
  prop :badge_label
  prop :badge_color, default: :blue
  prop :title
  prop :description
  prop :actions
  prop :action_icon, default: "avo/three-dots-vertical"
  prop :classes
end
