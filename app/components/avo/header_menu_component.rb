# frozen_string_literal: true

module Avo
  # Dumb presentational wrapper: the JS controller distributes the block's
  # children between a visible row and an overflow popover at runtime. The
  # component itself knows nothing about menu config or item structure.
  class HeaderMenuComponent < Avo::BaseComponent
  end
end
