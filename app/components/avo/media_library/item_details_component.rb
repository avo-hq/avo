# frozen_string_literal: true

module Avo
  module MediaLibrary
    class ItemDetailsComponent < Avo::BaseComponent
      include Turbo::FramesHelper
      include Avo::ApplicationHelper

      prop :blob

      # def parent_title(parent)
      #   # TODO: find the resource and get the title attribute from there
      #   parent.to_param
      # end

      # def parent_path(parent)
      #   # TODO: find the resource and get the path from there
      #   parent.to_param
      # end
    end
  end
end
