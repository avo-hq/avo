# frozen_string_literal: true

class Avo::ViewTypes::GridComponent < Avo::ViewTypes::BaseViewTypeComponent
  include Avo::ResourcesHelper

  def grid_card_for(resource)
    Avo::ExecutionContext.new(target: resource.grid_view[:card], resource: resource, record: resource.record).handle
  end
end
