module Avo
  module Fields
    class HiddenField < TextField

      class_attribute :supported_options, default: {}
      Avo::Fields::COMMON_OPTIONS.each do |common_option, hash|
        supports common_option, hash
      end

      def initialize(id, **args, &block)
        super(id, **args, &block)

        only_on :forms
      end
    end
  end
end
