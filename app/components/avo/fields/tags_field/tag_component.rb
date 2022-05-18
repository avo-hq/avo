# frozen_string_literal: true

class Avo::Fields::TagsField::TagComponent < ViewComponent::Base
  attr_reader :label
  attr_reader :title

  def initialize(label: nil, title: nil)
    @label = label
    @title = title
  end
end
