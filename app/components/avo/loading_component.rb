# frozen_string_literal: true

module Avo
  class LoadingComponent < ViewComponent::Base
    def initialize(title: nil)
      @title = title
    end
  end
end
