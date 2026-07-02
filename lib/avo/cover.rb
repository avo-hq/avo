# frozen_string_literal: true

module Avo
  class Cover < PhotoObject
    def key = :cover

    def size
      options.fetch(:size, :md)
    end
  end
end
