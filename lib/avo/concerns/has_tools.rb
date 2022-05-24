module Avo
  module Concerns
    module HasTools
      extend ActiveSupport::Concern

      included do
        class_attribute :tools_holder
      end

      class_methods do
        delegate :add_tool, to: ::Avo::Services::DslService

        def tool(klass, **args)
          self.tools_holder ||= []

          add_tool(tools_holder, klass, **args)
        end

        def tools
          self.tools_holder
        end
      end

      def tools
        # abort self.class.tools.inspect
        # abort self.inspect
        check_license

        return [] if App.license.lacks_with_trial :resource_tools
        return [] if self.class.tools.blank?
        # abort self.class.tools_holder.inspect

        self.tools_holder
          # .map do |tool|
          #   tool.hydrate view: view
          #   tool
          # end
          # .select do |field|
          #   # field.send("show_on_#{view}")
          #   true
          # end
      end

      private

      def check_license
        if !Rails.env.production? && App.license.present? && App.license.lacks(:resource_tools)
          # Add error message to let the developer know the resource tool will not be available in a production environment.
          Avo::App.error_messages.push "Warning: Your license is invalid or doesn't support resource tools. The resource tools will not be visible in a production environment."
        end
      end
    end
  end
end
