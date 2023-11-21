module Avo
  module Fields
    class PreviewField < BaseField
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
