# frozen_string_literal: true

class Avo::DescriptionListComponent < Avo::BaseComponent
  prop :classes, default: ""

  def call
    tag.div class: class_names("description-list", @classes) do
      content
    end
  end
end
