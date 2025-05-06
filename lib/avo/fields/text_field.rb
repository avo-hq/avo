module Avo
  module Fields
    class TextField < BaseField
      class_attribute :supported_options, default: {}

      Avo::Fields::COMMON_OPTIONS.each do |common_option, hash|
        supports common_option, hash
      end

      supports :link_to_record, default: false
      supports :as_html, default: false
      supports :protocol, default: false
    end
  end
end
