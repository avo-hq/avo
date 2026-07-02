# frozen_string_literal: true

class Avo::BreadcrumbsComponent < Avo::BaseComponent
  prop :items, default: -> { [] }
end
