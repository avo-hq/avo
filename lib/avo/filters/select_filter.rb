require_relative '../filter'

module Avo
  module Filters
    class SelectFilter < Avo::Filter
      self.template = 'avo/base/select_filter'
    end
  end
end
