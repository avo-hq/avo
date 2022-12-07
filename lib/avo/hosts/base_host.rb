require "dry-initializer"

# This object holds some data that is usually needed to compute blocks around the app.
module Avo
  module Hosts
    class BaseHost
      extend Dry::Initializer

      option :context, default: proc { Avo::Current.context }
      option :params, default: proc { Avo::Current.params }
      option :view_context, default: proc { Avo::Current.view_context }
      option :current_user, default: proc { Avo::Current.current_user }
      # This is optional because we might instantiate the `Host` first and later hydrate it with a block.
      option :block, optional: true

      delegate :authorize, to: Avo::Services::AuthorizationService

      def handle
        instance_exec(&block)
      end
    end
  end
end
