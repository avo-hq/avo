module Avocado
  module Tools
    class ResourceManager < Avocado::Tool
      def self.init
        'ResourceManager.initing'
      end

      def render_navigation
        # render 'navigation'
      end

      def load_resources
        abort 'load_resources'.inspect
      end
    end
  end
end
