module Avo
  module Fields
    class HasManyField < HasBaseField
      attr_accessor :hide_per_page_options_on_few_items
      attr_accessor :hide_per_page_counter

      def initialize(id, **args, &block)
        args[:updatable] = false

        @hide_per_page_options_on_few_items = args[:hide_per_page_options_on_few_items] || false
        @hide_per_page_counter = args[:hide_per_page_counter] || false
        hide_on :all
        show_on :show

        super(id, **args, &block)
      end
    end
  end
end
