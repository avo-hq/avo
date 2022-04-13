require "dry-initializer"

# This object holds some data tha is usually needed to compute blocks around the app.
module Avo
  module Hosts
    class BaseHost
      extend Dry::Initializer

      option :context, default: proc { Avo::App.context }
      option :params, default: proc { Avo::App.params }
      option :view_context, default: proc { Avo::App.view_context }
      option :current_user, default: proc { Avo::App.current_user }
      option :block, optional: true

      def handle
        instance_exec(&block)
      end
    end
  end
end
