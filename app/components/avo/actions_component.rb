# frozen_string_literal: true

class Avo::ActionsComponent < ViewComponent::Base
  include Avo::ApplicationHelper

  def initialize(actions: [], resource: nil)
    @actions = actions
    @resource = resource
  end

  def render?
    @actions.present?
  end
end
