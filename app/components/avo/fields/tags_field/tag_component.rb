# frozen_string_literal: true

class Avo::Fields::TagsField::TagComponent < Avo::BaseComponent
  attr_reader :label
  attr_reader :title

  def initialize(label: nil, title: nil)
    @label = label
    @title = title
  end
end
