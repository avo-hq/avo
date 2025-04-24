module Avo
  module Fields
    class PasswordField < TextField

      class_attribute :supported_options, default: {}
      Avo::Fields::COMMON_OPTIONS.each do |common_option, hash|
        supports common_option, hash
      end

      supports :revealable, default: false

      def initialize(id, **args, &block)
        show_on :forms

        super(id, **args, &block)

        hide_on :index, :show
      end
    end
  end
end
