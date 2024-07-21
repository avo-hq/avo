# frozen_string_literal: true

module Avo
  class CoverPhoto < PhotoObject
    def key = :cover_photo

    def size
      options.fetch(:size, :md)
    end
  end
end
