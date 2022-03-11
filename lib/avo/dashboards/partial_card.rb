module Avo
  module Dashboards
    class PartialCard < BaseCard
      class_attribute :empty, default: false
      class_attribute :partial
    end
  end
end
