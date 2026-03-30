# frozen_string_literal: true

class Avo::UI::PopoverComponent < Avo::BaseComponent
  prop :classes
  prop :trigger_classes
  prop :trigger_data, default: {}.freeze

  renders_one :trigger
  renders_one :items

  def popover_id
    @popover_id ||= "popover-#{SecureRandom.hex(3)}"
  end
end
