# frozen_string_literal: true

class Avo::Fields::Common::HeadingComponent < Avo::BaseComponent
  include Avo::Concerns::HasResourceStimulusControllers

  prop :field, Avo::Fields::BaseField
  prop :view, _Nilable(String) do |value|
    @field.resource.view
  end
  prop :classes, _Nilable(String) do |value|
    "flex items-start py-1 leading-tight bg-gray-100 text-gray-500 text-xs #{@field.get_html(:classes, view: @view, element: :wrapper)}"
  end
  prop :data, _Nilable(Hash) do |value|
    stimulus_data_attributes
  end

  def after_initialize
    add_stimulus_attributes_for(@field.resource, @data)
  end
end
