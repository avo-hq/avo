# frozen_string_literal: true

class Avo::UI::DropdownMenuComponent < Avo::BaseComponent
  prop :data, default: {}.freeze
  prop :classes
  prop :open, default: false
  prop :dropdown_menu_classes, default: ""
end
