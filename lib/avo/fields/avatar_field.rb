module Avo
  module Fields
    class AvatarField < BaseField
      def initialize(id, **args, &block)
        only_on :index

        super
      end

      def table_header_label
        @args[:name] || nil
      end

      def table_header_class
        "w-16"
      end
    end
  end
end
