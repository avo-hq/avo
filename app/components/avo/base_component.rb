# frozen_string_literal: true

class Avo::BaseComponent < ViewComponent::Base
  def has_with_trial(ability)
    ::Avo::App.license.has_with_trial(ability)
  end
end
