module Avo
  module Fields
    class TextareaField < TextField
      class_attribute :supported_options, default: {}
      Avo::Fields::COMMON_OPTIONS.each do |common_option, hash|
        supports common_option, hash
      end

      supports :rows

      def post_initialize
        hide_on :index
      end
    end
  end
end
