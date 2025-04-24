module Avo
  module Fields
    class TiptapField < BaseField
      class_attribute :supported_options, default: {}

      Avo::Fields::COMMON_OPTIONS.each do |common_option, hash|
        supports common_option, hash
      end

      supports :always_show, default: false

      def post_initialize
        hide_on :index
      end
    end
  end
end
