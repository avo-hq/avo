# frozen_string_literal: true

module Avo
  module MediaLibrary
    class ItemDetailsComponent < Avo::BaseComponent
      include Turbo::FramesHelper
      include Avo::ApplicationHelper

      prop :blob
    end
  end
end
