# frozen_string_literal: true

class Avo::DescriptionListComponent < Avo::BaseComponent
  def call
    tag.div class: class_names("description-list") do
      content
    end
  end
end
