module Avo
  module Fields
    class ProgressBarField < BaseField

      class_attribute :supported_options, default: {}
      Avo::Fields::COMMON_OPTIONS.each do |common_option, hash|
        supports common_option, hash
      end

      supports :max, default: 100
      supports :step, default: 1
      supports :display_value, default: false
      supports :value_suffix, default: nil
    end
  end
end
