# frozen_string_literal: true

class Avo::UI::DropdownCardComponent < Avo::BaseComponent
  renders_one :header
  renders_one :body
  renders_one :footer

  prop :classes
end
