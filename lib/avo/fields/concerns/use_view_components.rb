module Avo
  module Fields
    module Concerns
      module UseViewComponents
        extend ActiveSupport::Concern

        included do
          attr_reader :components
        end

        def view_component_name
          "#{type.camelize}Field"
        end

        # For custom components the namespace will be different than Avo::Fields so we should take that into account.
        def view_component_namespace
          "#{self.class.to_s.deconstantize}::#{view_component_name}"
        end

        # Try and build the component class or fallback to a blank one
        def component_for_view(view = :index)
          # Use the edit variant for all "update" views
          view = :edit if view.in? [:new, :create, :update]

          custom_components = Avo::ExecutionContext.new(
            target: components,
            resource: @resource,
            record: @record,
            view: view
          ).handle

          component_class = custom_components.dig("#{view}_component".to_sym) || "#{view_component_namespace}::#{view.to_s.camelize}Component"
          component_class.to_s.constantize
        rescue
          unless Rails.env.test?
            Avo.logger.info "Failed to find component for the `#{self.class}` field on the `#{view}` view."
          end
          # When returning nil, a race condition happens and throws an error in some environments.
          # See https://github.com/avo-hq/avo/pull/365
          ::Avo::BlankFieldComponent
        end
      end
    end
  end
end
