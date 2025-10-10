module Avo
  module Fields
    class TimeField < DateTimeField
      attr_reader :format
      attr_reader :picker_format

      def initialize(id, **args, &block)
        super(id, **args, &block)

        add_string_prop args, :picker_format, "H:i:S"
        add_string_prop args, :format, "TT"
      end
    end
  end
end
