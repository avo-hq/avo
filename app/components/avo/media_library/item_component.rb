# frozen_string_literal: true

module Avo
  module MediaLibrary
    class ItemComponent < Avo::BaseComponent
      with_collection_parameter :attachment

      prop :attachment, reader: :public
      prop :display_filename, default: true
      prop :attaching, default: false
    end
  end
end
