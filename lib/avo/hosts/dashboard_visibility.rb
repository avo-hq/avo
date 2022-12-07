require "dry-initializer"

module Avo
  module Hosts
    class DashboardVisibility
      extend Dry::Initializer

      option :block, default: proc { proc {} }
      option :current_user, default: proc { ::Avo::Current.current_user }
      option :context, default: proc { ::Avo::Current.context }
      option :dashboard
      option :params, default: proc { ::Avo::Current.params }

      def handle
        instance_exec(&block)
      end
    end
  end
end
