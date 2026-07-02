module Avo
  module ViewTypes
    class ViewTypeManager
      attr_reader :registry

      def initialize
        @registry = {}
      end

      def register(name, component:, icon:, active_icon:, translation_key: nil)
        @registry[name.to_sym] = {
          component: component,
          icon: icon,
          active_icon: active_icon,
          translation_key: translation_key
        }
      end

      def find(name)
        @registry[name.to_sym]
      end

      def component_for(name)
        entry = find(name)

        raise Avo::ViewTypeComponentNotFoundError, "No component registered for view type '#{name}'" unless entry

        component = entry[:component]
        component.is_a?(String) ? component.constantize : component
      end

      def registered?(name)
        @registry.key?(name.to_sym)
      end

      def reset
        @registry = {}
        register_defaults
      end

      private

      def register_defaults
        register :table,
          component: Avo::ViewTypes::TableComponent,
          icon: "tabler/outline/layout-list",
          active_icon: "tabler/filled/layout-list"

        register :grid,
          component: Avo::ViewTypes::GridComponent,
          icon: "tabler/outline/layout-grid",
          active_icon: "tabler/filled/layout-grid"

        register :map,
          component: Avo::ViewTypes::MapComponent,
          icon: "tabler/outline/compass",
          active_icon: "tabler/filled/compass"

        register :list,
          component: Avo::ViewTypes::TableComponent,
          icon: "tabler/outline/layout-list",
          active_icon: "tabler/filled/layout-list"
      end
    end
  end

  def self.view_type_manager
    @view_type_manager ||= Avo::ViewTypes::ViewTypeManager.new.tap(&:reset)
  end
end
