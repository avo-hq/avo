# frozen_string_literal: true

class Avo::Fields::TagsField::TagComponent < ViewComponent::Base
  with_collection_parameter :name
  attr_reader :name

  def initialize(name: nil)
    @name = name
  end
end
