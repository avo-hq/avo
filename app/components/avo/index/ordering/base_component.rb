# frozen_string_literal: true

class Avo::Index::Ordering::BaseComponent < ViewComponent::Base
  private

  def order_actions
    @resource.class.order_actions
  end
end
