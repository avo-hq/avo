module Avo
  module Concerns
    module HasTools
      extend ActiveSupport::Concern

      included do
        class_attribute :tools_holder

        def tools
          return [] if self.class.tools.blank?

          self.class.tools
            .map do |tool|
              tool.hydrate view: view
            end
            .select do |field|
              field.send("show_on_#{view}")
            end
        end
      end

      class_methods do
        def tool(klass, **args)
          self.tools_holder ||= []

          self.tools_holder << klass.new(**args)
        end

        def tools
          self.tools_holder
        end
      end
    end
  end
end
