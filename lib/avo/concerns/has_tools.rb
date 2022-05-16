module Avo
  module Concerns
    module HasTools
      extend ActiveSupport::Concern

      included do
        class_attribute :tools_holder

        def tools
          check_license

          return [] if App.license.lacks_with_trial :resource_tools
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

      private

      def check_license
        if !Rails.env.production? && App.license.lacks(:resource_tools)
          # Add error message to let the developer know the resource tool will not be available in a production environment.
          Avo::App.error_messages.push "Warning: Your license is invalid or doesn't support resource tools. The resource tools will not be visible in a production environment."
        end
      end
    end
  end
end
