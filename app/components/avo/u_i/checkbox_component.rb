# frozen_string_literal: true

class Avo::UI::CheckboxComponent < Avo::BaseComponent
  prop :checked, default: false
  prop :indeterminate, default: false
  prop :disabled, default: false
  prop :label
  prop :description
  prop :name
  prop :value
  prop :id
  prop :title
  prop :autocomplete, default: :off
  prop :data, default: -> { {} }
  prop :classes

  def state
    return :indeterminate if @indeterminate
    return :checked if @checked

    :unchecked
  end

  def indeterminate?
    state == :indeterminate
  end

  def computed_data
    data_hash = @data.dup
    data_hash[:indeterminate] = "true" if indeterminate?
    data_hash
  end
end
