# frozen_string_literal: true

class Avo::Index::Ordering::BaseComponent < Avo::BaseComponent
  private

  def order_actions
    @resource.class.order_actions
  end
end
