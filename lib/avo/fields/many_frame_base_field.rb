module Avo
  module Fields
    class ManyFrameBaseField < FrameBaseField

      class_attribute :supported_options, default: {}
      Avo::Fields::COMMON_OPTIONS.each do |common_option, hash|
        supports common_option, hash
      end

      Avo::Fields::FRAME_BASE_OPTIONS.each do |common_option, hash|
        supports common_option, hash
      end


      include Avo::Fields::Concerns::IsSearchable
      include Avo::Fields::Concerns::Nested

      supports :searchable
      supports :scope
      supports :hide_search_input
      supports :discreet_pagination

      def initialize(id, **args, &block)
        args[:updatable] = false

        initialize_nested(**args)

        if @nested[:on]
          if Avo.configuration.resource_default_view.edit?
            only_on Array.wrap(@nested[:on]) + [:edit]
          else
            only_on Array.wrap(@nested[:on]) + [:show]
          end
        else
          only_on Avo.configuration.resource_default_view
        end

        super(id, **args, &block)
      end
    end
  end
end
