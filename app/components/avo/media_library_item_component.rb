# frozen_string_literal: true

module Avo
  class MediaLibraryItemComponent < Avo::BaseComponent
    with_collection_parameter :attachment

    prop :attachment, reader: :public
    prop :display_filename, default: true
  end
end
