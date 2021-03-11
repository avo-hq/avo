require_relative '../filter'

module Avo
  module Filters
    class BooleanFilter < Avo::Filter
      self.template = 'avo/base/boolean_filter'
    end
  end
end
