# frozen_string_literal: true

class Avo::RowSelectorComponent < ViewComponent::Base
  def initialize(floating: false, size: :md)
    @floating = floating
    @size = size
  end
end
