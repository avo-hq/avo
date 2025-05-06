module Avo
  module Fields
    class PreviewField < BaseField

      class_attribute :supported_options, default: {}
      Avo::Fields::COMMON_OPTIONS.each do |common_option, hash|
        supports common_option, hash
      end

      def table_header_label
        # If the user gives us a name, use that, if not, leave it blank
        if @args[:name].present?
          @args[:name]
        else
          ""
        end
      end
    end
  end
end
