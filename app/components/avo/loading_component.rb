# frozen_string_literal: true

class Avo::LoadingComponent < ViewComponent::Base
  def initialize(title: nil)
    @title = title
  end
end
