# Adds the ability to set the visibility of an item in the execution context.
module Avo
  module Fields
    module Concerns
      module Nested
        extend ActiveSupport::Concern

        attr_reader :nested

        unless defined?(NESTED_DEFAULT)
          NESTED_DEFAULT = {
            on: [:new, :edit]
          }
        end

        def initialize_nested(**args)
          if args[:nested].nil?
            @nested = {}
            return
          end

          @nested = (args[:nested] == true) ? NESTED_DEFAULT : args[:nested]

          @nested[:on] = [:new, :edit] if @nested[:on] == :forms
        end

        def component_for_view(view = Avo::ViewInquirer.new("index"))
          view = Avo::ViewInquirer.new(view)

          nested_on?(view) ? Avo::Fields::Common::NestedFieldComponent : super(view)
        end

        def nested_on?(view)
          return false if view.display? || @nested[:on].nil?

          view = if view.create?
            "new"
          elsif view.update?
            "edit"
          else
            view
          end

          Array.wrap(@nested[:on]).map(&:to_s).include?(view)
        end
      end
    end
  end
end
