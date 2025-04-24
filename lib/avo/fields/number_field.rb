module Avo
  module Fields
    class NumberField < TextField

      class_attribute :supported_options, default: {}

      Avo::Fields::COMMON_OPTIONS.each do |common_option, hash|
        supports common_option, hash
      end

      supports :min
      supports :max
      supports :step
    end
  end
end
