# frozen_string_literal: true

class Avo::UI::DropdownComponent < Avo::BaseComponent
  prop :classes
  prop :data, default: {}.freeze

  prop :trigger_class
  prop :trigger_attrs, default: {}.freeze

  renders_one :trigger
  renders_one :items

  def unique_id
    @unique_id ||= "dropdown-#{SecureRandom.hex(4)}"
  end

  def popover_target
    "#{unique_id}-menu"
  end
end
